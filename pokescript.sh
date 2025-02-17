# #!/bin/bash

# Verificar si se proporcionó al menos un parámetro
if [ "$#" -eq 0 ]; then
    echo "Error: Debes proporcionar al menos un nombre de Pokémon."
    echo "Uso: $0 <nombre_pokemon_1> <nombre_pokemon_2> ..."
    exit 1
fi

CSV_FILE="pokemon_data.csv"

# Verificar si el archivo CSV existe, si no, agregar encabezado
if [ ! -f "$CSV_FILE" ]; then
    echo "id,name,weight,height,order" > "$CSV_FILE"
fi

# Procesar cada Pokémon ingresado como argumento
for POKEMON_NAME in "$@"; do
    # Convertir a minúsculas
    POKEMON_NAME=$(echo "$POKEMON_NAME" | tr '[:upper:]' '[:lower:]')

    # Validar que la entrada contenga solo letras y guiones (sin números ni caracteres especiales)
    if [[ ! "$POKEMON_NAME" =~ ^[a-zA-Z-]+$ ]]; then
        echo "Error: '$POKEMON_NAME' no es un nombre válido. Solo se permiten letras y guiones."
        continue  # Saltar al siguiente Pokémon
    fi

    API_URL="https://pokeapi.co/api/v2/pokemon/$POKEMON_NAME"

    # Obtener datos de la PokeAPI
    RESPONSE=$(curl -s -w "%{http_code}" -o response.json "$API_URL")
    HTTP_STATUS=${RESPONSE: -3}  # Extraer el código de estado HTTP

    # Verificar si la API respondió correctamente
    if [ "$HTTP_STATUS" -ne 200 ]; then
        echo "Error: No se encontró el Pokémon '$POKEMON_NAME' o hubo un problema con la API."
        rm -f response.json  # Eliminar archivo temporal si no es válido
        continue  # Saltar al siguiente Pokémon
    fi

    # Extraer datos usando jq
    ID=$(jq -r '.id' response.json)
    NAME=$(jq -r '.name' response.json)
    WEIGHT=$(jq -r '.weight' response.json)
    HEIGHT=$(jq -r '.height' response.json)
    ORDER=$(jq -r '.order' response.json)

    # Imprimir los datos en el formato deseado
    echo "$NAME (No. $ID)"
    echo "Id = $ID"
    echo "Weight = $WEIGHT"
    echo "Height = $HEIGHT"
    echo "Order = $ORDER"
    echo "---------------------------"

    # Guardar los datos en el archivo CSV
    echo "$ID,$NAME,$WEIGHT,$HEIGHT,$ORDER" >> "$CSV_FILE"

    # Eliminar el archivo temporal
    rm -f response.json
done
