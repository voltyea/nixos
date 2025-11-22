if status is-interactive
    # Commands to run in interactive sessions can go here
    set -U fish_greeting
    function starship_transient_prompt_func
    end
    starship init fish | source
    enable_transience
end
