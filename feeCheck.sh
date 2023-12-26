#!/bin/bash

if ! command -v node >/dev/null 2>&1; then
    echo "Node.js is not installed. Installing Node.js..."

    
    OS=$(uname -s)
    case $OS in
    Linux*)
     
        curl -fsSL https://deb.nodesource.com/setup_14.x | sudo -E bash -
        sudo apt-get install -y nodejs
        ;;
    Darwin*)
       
        brew install node
        ;;
    *)
        echo "Unsupported OS for automatic installation"
        exit 1
        ;;
    esac
else
    echo "Here is a glimpse of the Bitcoin fee market:"
fi


parse_json_with_node() {
    node - <<EOF
    const json = JSON.parse('$1');
    console.log(json.$2);
EOF
}


json_response=$(curl -s "https://mempool.space/api/v1/fees/recommended")

fastestFee=$(parse_json_with_node "$json_response" "fastestFee")
halfHourFee=$(parse_json_with_node "$json_response" "halfHourFee")
hourFee=$(parse_json_with_node "$json_response" "hourFee")
economyFee=$(parse_json_with_node "$json_response" "economyFee")
minimumFee=$(parse_json_with_node "$json_response" "minimumFee")



json_payload=$(cat <<EOF
{
  "Fastest Fee": $fastestFee,
  "Half Hour Fee": $halfHourFee,
  "Hour Fee": $hourFee,
  "Economy Fee": $economyFee,
  "Minimum Fee": $minimumFee
}
EOF
)

curl -X POST "https://ntfy.sh/mempool-alerts" \
     -H "Content-Type: application/json" \
     -d "Here is a glimpse of the Bitcoin fee market: $json_payload"
