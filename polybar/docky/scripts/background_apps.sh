#!/bin/bash

dir="$HOME/.config/polybar/docky/scripts/rofi"  # Utiliza $HOME en lugar de ~ para la variable dir.

# Lista de nombres de las aplicaciones que deseamos buscar automáticamente.
declare -a apps=("Discord" "flameshot" "steam" "docker")

# Filtrar las aplicaciones en ejecución y agregarlas a la lista de aplicaciones activas.
active_apps=()
for app in "${apps[@]}"; do
    if pgrep "$app" >/dev/null; then
        active_apps+=("$app")
    fi
done

if [ ${#active_apps[@]} -eq 0 ]; then
    # Si no hay aplicaciones en segundo plano, mostrar un mensaje en una ventana nueva.
    rofi -markup -e "<span foreground='Snow'><b>No hay aplicaciones en segundo plano</b></span>" -config "$dir/background_apps.rasi"
else
    # Mostrar el menú de aplicaciones activas.
    chosen_app=$(printf "%s\n" "${active_apps[@]}" | rofi -dmenu -p "Aplicaciones:" -config "$dir/background_apps.rasi")

    # Si se selecciona una aplicación, mostrar un segundo menú con las opciones "Abrir" o "Cerrar".
    if [ -n "$chosen_app" ]; then
        # Mostrar el menú secundario solo con las opciones "Abrir" o "Cerrar".
        action=$(echo -e "Abrir\nCerrar" | rofi -dmenu -p "Acción para $chosen_app:" -config "$dir/background_apps2.rasi")

        case "$action" in
            "Abrir")
                # Si la aplicación seleccionada es "Discord", siempre ejecutar el lanzador.
                if [ "$chosen_app" == "Discord" ]; then
                    discord &
                elif [ "$chosen_app" == "flameshot" ]; then  # Corregir la condición del if.
                    flameshot gui &
                elif [ "$chosen_app" == "steam" ]; then  # Corregir la condición del if.
                    steam &
                else
                    # Verificar si la ventana ya existe y activarla si es el caso.
                    if xdotool search --name "$chosen_app" windowactivate >/dev/null 2>&1; then
                        # Si la ventana existe, activarla.
                        xdotool search --name "$chosen_app" windowactivate
                    else
                        # Si la ventana no existe y la aplicación no es "Discord", abrir una nueva instancia.
                        setsid "$chosen_app" >/dev/null 2>&1 &
                    fi
                fi
                ;;
            "Cerrar")
                pkill "$chosen_app"
                ;;
        esac
    fi
fi
