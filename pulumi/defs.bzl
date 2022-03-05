""""""

load("//pulumi:up.bzl", _pulumi_up = "pulumi_up")
load("//pulumi:preview.bzl", _pulumi_preview = "pulumi_preview")
load("//pulumi:toolchain.bzl", _pulumi_register_toolchains = "pulumi_register_toolchains")

pulumi_register_toolchains = _pulumi_register_toolchains

pulumi_preview = _pulumi_preview

pulumi_up = _pulumi_up
