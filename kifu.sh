#!/bin/bash

# Make sure a url is given as argument
if [ $# -eq 0 ]; then
  echo "Include URL as argument."
  exit
fi

# Get the source of the website warz shows kifu on and cut to the part we want
source=$(wget $1 -q -O -)
source=${source#*gamedata}
source=${source#*\"}

# Save the useful parts of the source in variables
player_one=${source%%-*}
source=${source#*-}
player_two=${source%%-*}
source=${source#*-}
hiduke=${source%%\"*}
source=${source#*dan0: \"}
player_one_dan=${source%%\"*}
source=${source#*dan1: \"}
player_two_dan=${source%%\"*}
source=${source#*receiveMove(\"}
moves=${source%%\"*}

# Make the filename to save the kifu in
printf -v filename "%s-%s-%s.kif" $player_one $player_two $hiduke

# Print the player info and header
printf "先手：%s %s\n" $player_one $player_one_dan > $filename
printf "後手：%s %s\n" $player_two $player_two_dan >> $filename
echo "手数----指手--" >> $filename

# Track whether or not the piece in a position is promoted
declare -A promoted_in_position
for ((i=1;i<=9;i++)) do
  for ((j=1;j<=9;j++)) do
    promoted_in_position[$i,$j]=false
  done
done

# Function to translate piece names into kanji
# $1 - a two-character string piece representation as used by warz
# $2 - bool: whether or not the piece moving is already promoted
translate_piece()
{
  piece="歩"
  if [ $1 == "KY" ]; then
    piece="香"
  elif [ $1 == "KE" ]; then
    piece="桂"
  elif [ $1 == "GI" ]; then
    piece="銀"
  elif [ $1 == "KI" ]; then
    piece="金"
  elif [ $1 == "KA" ]; then
    piece="角"
  elif [ $1 == "HI" ]; then
    piece="飛"
  elif [ $1 == "OU" ]; then
    piece="玉"
  elif [ $1 == "TO" ]; then
    if [ $2 == true ]; then
      piece="と"
    else
      piece="歩成"
    fi
  elif [ $1 == "NY" ]; then
    if [ $2 == true ]; then
      piece="成香"
    else
      piece="香成"
    fi
  elif [ $1 == "NK" ]; then
    if [ $2 == true ]; then
      piece="成桂"
    else
      piece="桂成"
    fi
  elif [ $1 == "NG" ]; then
    if [ $2 == true ]; then
      piece="成銀"
    else
      piece="銀成"
    fi
  elif [ $1 == "UM" ]; then
    if [ $2 == true ]; then
      piece="馬"
    else
      piece="角成"
    fi
  elif [ $1 == "RY" ]; then
    if [ $2 == true ]; then
      piece="龍"
    else
      piece="飛成"
    fi
  fi
  echo $piece
}

move_count=1
# Print the moves in kifu format one by one
for move in $moves; do
  orig=${move:1:2}
  dest=${move:3:2}
  piece_romaji=${move:5:2}

  # Check for game over (S"EN"TE/G"OT"E WIN, D"RA"W)
  if [[ $orig == "EN" || $orig == "OT" ]]; then
    printf "%s 投了" $move_count >> $filename
    exit
  elif [ $orig == "RA" ]; then
    printf "%s 千日手" $move_count >> $filename
    exit
  fi

  # Get the piece name in kanji
  already_promoted=false
  if [ ! $orig == 00 ]; then
    already_promoted=${promoted_in_position[${orig:0:1},${orig:1:1}]}
  fi
  piece=$(translate_piece $piece_romaji $already_promoted)
  # Update the promoted_in_position matrix
  if [ $already_promoted == true ]; then
    promoted_in_position[${dest:0:1},${dest:1:1}]=true
    promoted_in_position[${orig:0:1},${orig:1:1}]=false
  elif [ ${#piece} == 2 ]; then
    if [ ${piece:1:1} == "成" ]; then
      promoted_in_position[${dest:0:1},${dest:1:1}]=true
    fi
  fi

  # uchi holds either "(orig)" or "打" for printing
  printf -v uchi "(%s)" $orig
  if [ $orig == 00 ]; then
    uchi="打"
  fi

  # print the move in kifu format
  printf "%s %s%s%s\n" $move_count $dest $piece $uchi >> $filename
  ((++move_count))
done

















#
