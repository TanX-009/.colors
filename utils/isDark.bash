#!/bin/bash

# Check if ImageMagick is installed
if ! command -v magick &>/dev/null; then
	echo "ImageMagick is not installed. Please install it and try again."
	exit 1
fi

# Check if an image file was provided
if [ -z "$1" ]; then
	echo "Usage: $0 <image_file>"
	exit 1
fi

IMAGE_FILE="$1"

# Check if the file exists
if [ ! -f "$IMAGE_FILE" ]; then
	echo "File not found: $IMAGE_FILE"
	exit 1
fi

# Calculate the average brightness
# Convert the image to grayscale, get the average brightness
AVG_BRIGHTNESS=$(magick "$IMAGE_FILE" -colorspace Gray -format "%[fx:mean*100]" info:)

# Print the average brightness for debugging
# echo "Average Brightness: $AVG_BRIGHTNESS"

# Set the threshold for light or dark theme
THRESHOLD=50.0

# Function to compare floating point numbers in Bash
compare_floats() {
	awk -v num1="$1" -v num2="$2" 'BEGIN {print (num1 > num2)}'
}

# Determine if the image is suitable for a light or dark theme
if [ "$(compare_floats "$AVG_BRIGHTNESS" "$THRESHOLD")" -eq 1 ]; then
	echo "light"
else
	echo "dark"
fi
