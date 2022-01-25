# return the value of the given key ${1}
# from the json at the given path ${2}
function value(){
  local args="${1}" configuration_file=${2};
  # JQ returns an error when a key begin with a number unless
  # we surround it with single and double quotes '"key"'
  # but dont recognize alpha keys quoted this way
  [[ ${args::1} =~ ^[0-9]$ ]] && args=$( printf '"%s"' $args );

  local output=$($HITCH_JQ ."$args" $configuration_file);
  echo $output | tr -d '[],"';
}

# list the keys of the json at the given path ${1}, if
# two params are given list the #keys of the json
# object ${1} in the json at the path ${2}
function keys(){
  if [[ -z ${2+x} ]]
  then
    local configuration_file="$1";
    local args="";
  else
    local configuration_file="$2";
    local args=".$1 |";
    [[ ${args::1} =~ ^[0-9]$ ]] && args=$( printf '"%s"' $args );
  fi
  $HITCH_JQ "${args} keys_unsorted" $configuration_file | tr -d '[],"';
}

function update(){
  local field="${1}" value="${2}" json="${3}";
  echo "$( $HITCH_JQ --arg value "$value" ."$field"' = $value' $json )" > $json;
}

# return the absolute path of any given relative
# to HITCH root path ${1} or leave any
# given absolute path ${1} unchanged
function path(){
  if [[ -z ${1+x} ]]
  then
    echo "$HITCH_PWD";
  else
    local path="${1}";
    [[ $path =~ ^/|^~/ ]] && echo "$path" || echo "$HITCH_PWD/$path";
  fi
}

# return the value of the given ${1} option
# from the user app.json file if not null
# otherwise from the default app.json
function app(){
  local args="${1}";

  local configs="$HITCH_PWD/configs";
  local value="null";

  local user_config=$( path "$configs/app.json" );

  if is_file $user_config
  then
    value=$( value $args $user_config );
  fi

  if is_null $value
  then
    local defaults=$( path "$configs/defaults/app.json" );
    value=$( value $args $defaults );
  fi
  echo $value;
}