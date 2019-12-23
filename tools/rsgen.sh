#!/bin/bash

prng="/dev/urandom"

generate_random_string()
{
    generated=$(tr -dc "[:$1:]" < "$2" | tr -d "$3" | head -c "$4")
    if [[ "$5" == "uc" ]]; then generated=$(printf "$generated" | tr [:lower:] [:upper:]); fi
    if [[ "$5" == "lc" ]]; then generated=$(printf "$generated" | tr [:upper:] [:lower:]); fi
    
    printf "$generated"
}

rsgen_alnum()
{
    type="alnum"
    except=""
    length=$1
    capstyle="$2"
    
    generated=$(generate_random_string "$type" "$prng" "$except" "$length" "$capstyle")
    
    printf "$generated"
}

rsgen_al()
{
    type="alpha"
    except=""
    length=$1
    capstyle="$2"
    
    generated=$(generate_random_string "$type" "$prng" "$except" "$length" "$capstyle")
    
    printf "$generated"
}

rsgen_num()
{
    type="digit"
    except=""
    length=$1

    generated=$(generate_random_string "$type" "$prng" "$except" "$length")
    
    printf "$generated"
}

rsgen_hex()
{
    type="xdigit"
    except=""
    length=$1
    capstyle="$2"
    
    generated=$(generate_random_string "$type" "$prng" "$except" "$length" "$capstyle")
    
    printf "$generated"
}

rsgen_allexcept()
{
    type="graph"
    except="\''\\'\`'``'\/$1"
    length=$2
    capstyle="$3"
    
    generated=$(generate_random_string "$type" "$prng" "$except" "$length" "$capstyle")
    
    printf "%s" "$generated"
}
