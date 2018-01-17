# Be sure to install icons-in-terminal font and source 
# icons_bash.sh before loading the antigen

: ${omg_ungit_prompt:=$PS1}
: ${omg_second_line:="%~ • "}
: ${omg_is_a_git_repo_symbol:=$oct_octoface}
: ${omg_has_untracked_files_symbol:=$fa_recycle}
: ${omg_has_adds_symbol:=$fa_plus}
: ${omg_has_deletions_symbol:=$fa_minus}
: ${omg_has_cached_deletions_symbol:=$fa_minus_circle}
: ${omg_has_modifications_symbol:=$fa_pencil}
: ${omg_has_cached_modifications_symbol:=$fa_plus_circle}
: ${omg_ready_to_commit_symbol:=$fa_check_square}
: ${omg_is_on_a_tag_symbol:=$fa_tag}
: ${omg_needs_to_merge_symbol:=$oct_git_merge}
: ${omg_detached_symbol:=$fa_chain_broken}
: ${omg_can_fast_forward_symbol:=$md_fast_forward}
: ${omg_has_diverged_symbol:=$oct_repo_forked} 
: ${omg_not_tracked_branch_symbol:=$fa_laptop}
: ${omg_rebase_tracking_branch_symbol:=$md_import_export} 
: ${omg_merge_tracking_branch_symbol:=$oct_git_branch}   
: ${omg_should_push_symbol:=$fa_cloud_upload}           
: ${omg_has_stashes_symbol:=$oct_star}
: ${omg_has_action_in_progress_symbol:=$fa_exclamation_triangle} 

autoload -U colors && colors

PROMPT='$(build_prompt)'
RPROMPT='%{$reset_color%}%T %{$fg_bold[white]%} %n@%m%{$reset_color%}'

function enrich_append {
    local flag=$1
    local symbol=$2
    local color=${3:-$omg_default_color_on}
    if [[ $flag == false ]]; then symbol=' '; fi

    echo -n "${color}${symbol}  "
}

function custom_build_prompt {
    local enabled=${1}
    local current_commit_hash=${2}
    local is_a_git_repo=${3}
    local current_branch=$4
    local detached=${5}
    local just_init=${6}
    local has_upstream=${7}
    local has_modifications=${8}
    local has_modifications_cached=${9}
    local has_adds=${10}
    local has_deletions=${11}
    local has_deletions_cached=${12}
    local has_untracked_files=${13}
    local ready_to_commit=${14}
    local tag_at_current_commit=${15}
    local is_on_a_tag=${16}
    local has_upstream=${17}
    local commits_ahead=${18}
    local commits_behind=${19}
    local has_diverged=${20}
    local should_push=${21}
    local will_rebase=${22}
    local has_stashes=${23}
    local action=${24}

    local prompt=""
    local original_prompt=$PS1


    local black_on_white="%K{white}%F{black}"
    local black_on_yellow="%K{yellow}%F{black}"
    local yellow_on_white="%K{white}%F{yellow}"
    local red_on_white="%K{white}%F{red}"
    local red_on_black="%K{black}%F{red}"
    local black_on_red="%K{red}%F{black}"
    local white_on_red="%K{red}%F{white}"
    local white_on_yellow="%K{yellow}%F{white}"
    local yellow_on_red="%K{red}%F{yellow}"
    local red_on_yellow="%K{yellow}%F{red}"
    local green_on_yellow="%K{yellow}%F{green}"
    local green_on_white="%K{white}%F{green}"
 
    # Flags
    local omg_default_color_on="${black_on_white}"

    local current_path="%~"

    if [[ $is_a_git_repo == true ]]; then
        # on filesystem
        prompt="${black_on_white} "
        prompt+=$(enrich_append $is_a_git_repo $omg_is_a_git_repo_symbol "${black_on_white}")
        prompt+=$(enrich_append $has_stashes $omg_has_stashes_symbol "${yellow_on_white}")

        prompt+=$(enrich_append $has_untracked_files $omg_has_untracked_files_symbol "${red_on_white}")
        prompt+=$(enrich_append $has_modifications $omg_has_modifications_symbol "${red_on_white}")
        prompt+=$(enrich_append $has_deletions $omg_has_deletions_symbol "${red_on_white}")
        

        # ready
        prompt+=$(enrich_append $has_adds $omg_has_adds_symbol "${black_on_white}")
        prompt+=$(enrich_append $has_modifications_cached $omg_has_cached_modifications_symbol "${black_on_white}")
        prompt+=$(enrich_append $has_deletions_cached $omg_has_cached_deletions_symbol "${black_on_white}")
        
        # next operation

        prompt+=$(enrich_append $ready_to_commit $omg_ready_to_commit_symbol "${green_on_white}")
        prompt+=$(enrich_append $action "${omg_has_action_in_progress_symbol} $action" "${red_on_white}")

        # where

        prompt="${prompt} ${white_on_yellow} ${black_on_yellow}"
        if [[ $detached == true ]]; then
            prompt+=$(enrich_append $detached $omg_detached_symbol "${black_on_yellow}")
            prompt+=$(enrich_append $detached "(${current_commit_hash:0:7})" "${black_on_yellow}")
        else            
            if [[ $has_upstream == false ]]; then
                prompt+=$(enrich_append true "-- ${omg_not_tracked_branch_symbol}  --  (${current_branch})" "${black_on_yellow}")
            else
                if [[ $will_rebase == true ]]; then
                    local type_of_upstream=$omg_rebase_tracking_branch_symbol
                else
                    local type_of_upstream=$omg_merge_tracking_branch_symbol
                fi

                if [[ $has_diverged == true ]]; then
                    prompt+=$(enrich_append true "-${commits_behind} ${omg_has_diverged_symbol} +${commits_ahead}" "${black_on_yellow}")
                else
                    if [[ $commits_behind -gt 0 ]]; then
                        prompt+=$(enrich_append true "-${commits_behind} %F{white}${omg_can_fast_forward_symbol}%F{black} --" "${black_on_yellow}")
                    fi
                    if [[ $commits_ahead -gt 0 ]]; then
                        prompt+=$(enrich_append true "-- %F{white}${omg_should_push_symbol}%F{black}  +${commits_ahead}" "${black_on_yellow}")
                    fi
                    if [[ $commits_ahead == 0 && $commits_behind == 0 ]]; then
                         prompt+=$(enrich_append true " --   -- " "${black_on_yellow}")
                    fi
                    
                fi
                prompt+=$(enrich_append true "(${current_branch} ${type_of_upstream} ${upstream//\/$current_branch/})" "${black_on_yellow}")
            fi
        fi
        prompt+=$(enrich_append ${is_on_a_tag} "${omg_is_on_a_tag_symbol} ${tag_at_current_commit}" "${white_on_yellow}")
        prompt+="%k%F{yellow}%k%f
${omg_second_line}"
    else
        prompt="${omg_ungit_prompt}"
    fi
 
    echo "${prompt}"
}
