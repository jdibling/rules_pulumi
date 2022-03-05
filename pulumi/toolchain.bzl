""""""

load("//pulumi:provider.bzl", "PulumiInfo")

toolchains = {
    "linux_amd64": {
        "arch": "amd64",
        "exec_compatible_with": [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        "os": "linux",
        "sha": "43806e68f7af396449dd4577c6e5cb63c6dc4a253ae233e1dddc46cf423d808b",
        "target_compatible_with": [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
    },
    "macos_amd64": {
        "arch": "amd64",
        "exec_compatible_with": [
            "@platforms//os:osx",
            "@platforms//cpu:x86_64",
        ],
        "os": "darwin",
        "sha": "2c2d9d435712f4be989738b7899917ced7c12ab05b8ddc14359ed4ddb1bc9375",
        "target_compatible_with": [
            "@platforms//os:osx",
            "@platforms//cpu:x86_64",
        ],
    },
}

url_template = "https://get.pulumi.com/releases/sdk/pulumi-v{version}-{arch}.tar.gz"

def _pulumi_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        barcinfo = PulumiInfo(
            sha = ctx.attr.sha,
            url = ctx.attr.url,
        ),
    )
    return [toolchain_info]

pulumi_toolchain = rule(
    implementation = _pulumi_toolchain_impl,
    attrs = {
        "sha": attr.string(),
        "url": attr.string(),
    },
)

def _format_url(version, os, arch):
    return url_template.format(version = version, os = os, arch = arch)

def _detect_platform_arch(ctx):
    if ctx.os.name == "linux":
        platform = "linux"
        res = ctx.execute(["uname", "-m"])
        if res.return_code == 0:
            uname = res.stdout.strip()
            if uname not in ["x86_64", "i386"]:
                fail("Unable to determing processor architecture.")

            arch = "amd64" if uname == "x86_64" else "i386"
        else:
            fail("Unable to determing processor architecture.")
    elif ctx.os.name == "mac os x":
        platform, arch = "darwin", "amd64"
    elif ctx.os.name.startswith("windows"):
        platform, arch = "windows", "amd64"
    else:
        fail("Unsupported operating system: " + ctx.os.name)

    return platform, arch

def _pulumi_build_file(ctx, platform, version):
    ctx.file("ROOT")
    ctx.template(
        "BUILD.bazel",
        Label("@io_bazel_rules_pulumi//pulumi:BUILD.pulumi.bazel"),
        executable = False,
        substitutions = {
            "{exe}": ".exe" if platform == "windows" else "",
            "{name}": "pulumi_executable",
            "{version}": version,
        },
    )

def _remote_pulumi(ctx, url, sha):
    ctx.download_and_extract(
        url = url,
        sha256 = sha,
        type = "tar.gz",
        output = "pulumi",
    )

def _pulumi_register_toolchains_impl(ctx):
    platform, arch = _detect_platform_arch(ctx)
    version = ctx.attr.version
    _pulumi_build_file(ctx, platform, version)

    host = "{}_{}".format(platform, arch)
    info = toolchains[host]
    url = _format_url(version, info["os"], info["arch"])
    _remote_pulumi(ctx, url, info["sha"])

_pulumi_register_toolchains = repository_rule(
    _pulumi_register_toolchains_impl,
    attrs = {
        "version": attr.string(),
    },
)

def pulumi_register_toolchains(version = None):
    # TODO version is required
    _pulumi_register_toolchains(
        name = "register_pulumi_toolchains",
        version = version,
    )