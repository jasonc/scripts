#!/bin/bash

# This script takes a file containing a list of URLs, one per line, as an argument.
# It only prints the URLs that return a 200 HTTP response code.
# Example usage: ./${0} /tmp/urls.txt | tee good-urls.txt

# If the user doesn't supply at least one argument, then give them help.
if [[ "${#}" -lt 1 ]]
then
  echo "Usage: ${0} FILE_OF_URLS..."
  exit 1
fi

# Loop through the list of files provided.
for URL_FILE in "${@}"
do
  # Loop through the URLs in the file.
  while read -r LINE
  do
    # Skip lines that are commented out.
    [[ "${LINE}" =~ ^#.* ]] && continue

    # Only print URLs that return a 200 HTTP response code.
    curl -sI ${LINE} | head -1 | grep '200' &>/dev/null
    [[ "${?}" -eq 0 ]] && echo $LINE
  done < ${URL_FILE}
done
