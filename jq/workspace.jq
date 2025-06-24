import "fzf" as fzf;

def list:
  [ (.workspaces | to_entries[] | { "key": .key,   "value": { "data":     .value }})
  , (.registers  | to_entries[] | { "key": .value, "value": {"registers": [.key] }})
  ]
  | group_by(.key)
  | [ .[]
      | { "workspace": .[0].key
        , "registers": [(.[].value.registers // [])[]]
      }
    ]
  | sort_by((.value.registers | - length), .key)
;

def display:
  [ .[]
    | { "search": .workspace, "data": { "workspace": .workspace } | @json, "display": .registers }
  ]
;
