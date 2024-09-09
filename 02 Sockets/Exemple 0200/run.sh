#!/bin/bash

# Exemple de funcionament: ./run.sh Client
# on 'Client' o 'Server' són els paràmetres que indiquen quina classe volem executar

# Set MAVEN_OPTS environment variable
export MAVEN_OPTS="--add-opens java.base/java.lang=ALL-UNNAMED --add-opens java.base/java.nio=ALL-UNNAMED --add-opens java.base/java.util=ALL-UNNAMED -Dfile.encoding=UTF8"

# Verifica si el paràmetre s'ha passat
if [ -z "$1" ]; then
  echo "Error: Has de passar un argument: 'Client' o 'Server'."
  exit 1
fi

# Assigna el perfil en funció del paràmetre passat
if [ "$1" == "Client" ]; then
  profile="runClient"
  mainClass="com.project.Client"
elif [ "$1" == "Server" ]; then
  profile="runServer"
  mainClass="com.project.Server"
else
  echo "Error: L'argument ha de ser 'Client' o 'Server'."
  exit 1
fi

echo "Setting MAVEN_OPTS to: $MAVEN_OPTS"
echo "Executing Maven profile: $profile with Main Class: $mainClass"

# Execució de la comanda Maven
mvn -q clean test-compile exec:java -P$profile -Dexec.mainClass=$mainClass
