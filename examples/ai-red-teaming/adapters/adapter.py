"""Text-only broker exercise. Replace the response with your application's call."""


def call_target(context, inference_input):
    return CallTargetResult(output=context.vars["message"])
