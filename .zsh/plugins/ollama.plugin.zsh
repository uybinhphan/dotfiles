export OLLAMA_USE_MLX=1
export OLLAMA_FLASH_ATTENTION=1
export OLLAMA_KV_CACHE_TYPE=q8_0

if type ollama &>/dev/null && (( $+functions[compdef] )); then
    _ollama_models() {
        local -a models
        models=("${(@f)$(curl -fsS http://127.0.0.1:11434/api/tags 2>/dev/null | tr '{},' '\n' | awk -F\" '/"name":/ {print $4}')}")
        compadd -a models
    }

    _ollama() {
        local -a commands
        commands=(
            'run:run a model'
            'show:show model information'
            'pull:pull a model'
            'rm:remove a model'
            'cp:copy a model'
            'list:list models'
            'ps:list running models'
            'serve:start ollama server'
            'stop:stop a running model'
        )

        if (( CURRENT == 2 )); then
            _describe 'ollama commands' commands
        elif (( CURRENT == 3 )); then
            case "${words[2]}" in
                run|show|rm|cp|stop)
                    _ollama_models
                    ;;
                *)
                    _files
                    ;;
            esac
        else
            _files
        fi
    }

    compdef _ollama ollama
fi
