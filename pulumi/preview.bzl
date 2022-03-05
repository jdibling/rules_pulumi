""""""

def _pulumi_preview(ctx):
    deps = depset(ctx.files.srcs)
    ctx.actions.run(
        executable = ctx.executable._exec,
        inputs = deps.to_list(),
        outputs = [ctx.outputs.out],
        mnemonic = "PulumiPreview",
        arguments = [
            "preview",
            "-j",
        ],
    )

pulumi_preview = rule(
    implementation = _pulumi_preview,
    attrs = {
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = True,
        ),
        "_exec": attr.label(
            default = Label("@register_pulumi_toolchains//:pulumi_executable"),
            allow_files = True,
            executable = True,
            cfg = "host",
        ),
    },
    outputs = {"out": "%{name}.json"},
    executable = True,
)