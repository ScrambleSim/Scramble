extends Node

# What animation to play -1=standing 0=walking 1=running
func set_animation(animation_index):
    $"WalkTween".interpolate_property(
        $"../Visuals/AnimationTree",
        "parameters/movement/blend_amount",
        $"../Visuals/AnimationTree".get("parameters/movement/blend_amount"),
        animation_index,
        0.1,
        Tween.TRANS_LINEAR
    )
    $"WalkTween".start()
