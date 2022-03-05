""""""

def _pulumi_up(ctx):
    deps = depset(ctx.files.srcs)
    ctx.actions.run(
        executable = ctx.executable._exec,
        inputs = deps.to_list(),
        outputs = [ctx.outputs.out],
        mnemonic = "PulumiUp",
        arguments = [
            "up",
            "-y",
        ],
    )

pulumi_up = rule(
    implementation = _pulumi_up,
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
    outputs = {"out": "%{name}.out"},
    executable = True,
)