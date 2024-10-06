<div style="display: flex; width: 100%;">
    <div style="flex: 1; padding: 0px;">
        <p>© Albert Palacios Jiménez, 2024</p>
    </div>
    <div style="flex: 1; padding: 0px; text-align: right;">
        <img src="./assets/ieti.png" height="32" alt="Logo de IETI" style="max-height: 32px;">
    </div>
</div>
<br/>

# Proxmox IETI

## Accedir al Proxmox per SSH

ssh -i id_rsa -p 20127 nomUsuari@ieticloudpro.ieti.cat

Suposant que 'id_rsa' és l'arxiu que té la clau privada d'accés al Proxmox

## Desinstal·lar apache

sudo systemctl stop apache2
sudo apt remove apache2
sudo apt purge apache2
sudo rm -rf /var/www/html
sudo apt autoremove
apache2 -v

- Ha de dir: bash: /usr/sbin/apache2: No such file or directory

## Instal·lar Java MVN

sudo apt update
sudo apt install net-tools
sudo apt install openjdk-21-jre-headless
sudo apt install maven
mvn -v

- Ha de dir (semblant): Apache Maven 3.6.3

## Generar un arxiu .jar per pujar al servidor

Comprovar que **'pom.xml'** té el plugin **'maven-jar-plugin'**

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-shade-plugin</artifactId>
    <version>3.3.0</version>
    <executions>
        <execution>
            <phase>package</phase>
            <goals>
                <goal>shade</goal>
            </goals>
            <configuration>
                <transformers>
                    <transformer implementation="org.apache.maven.plugins.shade.resource.ManifestResourceTransformer">
                        <mainClass>com.project.Server</mainClass> 
                    </transformer>
                </transformers>
                <finalName>server-package</finalName>
            </configuration>
        </execution>
    </executions>
</plugin>
```

Comprovar que el **'run.sh'** té la opció de generar paquets **.jar**:

```sh
mainClass=$1
action=$2 

echo "Setting MAVEN_OPTS to: $MAVEN_OPTS"
echo "Main Class: $mainClass"

if [[ "$action" == "build" ]]; then
    echo "Generating JAR file with all dependencies..."
    mvn clean package -Dmaven.test.skip=true
    echo "JAR generated in target directory."
    if [ -f target/server-package.jar ]; then
        echo "Successfully generated JAR: target/server-package.jar"
    else
        echo "Failed to generate JAR."
        exit 1
    fi
else
    # Execute mvn command with the profile and main class as arguments
    execArg="-PrunMain -Dexec.mainClass=$mainClass -Djavafx.platform=$javafx_platform"
    echo "Exec args: $execArg"

    # Execute mvn command
    mvn clean test-compile exec:java $execArg -X
fi
```

O bé el **'run.ps1'**:

```powershell
# Obtén los argumentos
$mainClass = $args[0]
$action = $args[1]

# Define la plataforma JavaFX
$javafx_platform = "win"

# Configura MAVEN_OPTS
$MAVEN_OPTS = "--add-opens java.base/java.lang=ALL-UNNAMED --add-opens java.base/java.nio=ALL-UNNAMED --add-opens java.base/java.util=ALL-UNNAMED --module-path $FX_PATH --add-modules javafx.controls,javafx.fxml,javafx.graphics"
# Opcions específiques per a Windows
$MAVEN_OPTS += " -Xdock:icon=./target/classes/icons/iconOSX.png" # Si necessites aquesta opció, la pots mantenir

Write-Output "Setting MAVEN_OPTS to: $MAVEN_OPTS"
Write-Output "Main Class: $mainClass"

if ($action -eq "build") {
    Write-Output "Generating JAR file with all dependencies..."
    mvn clean package -Dmaven.test.skip=true
    Write-Output "JAR generation completed."
    
    # Comprova si el JAR ha estat creat correctament
    $jarPath = "target\server-package.jar"  # Substitueix per el nom que has definit
    if (Test-Path $jarPath) {
        Write-Output "Successfully generated JAR: $jarPath"
    } else {
        Write-Output "Failed to generate JAR."
        exit 1
    }
    
    exit 0
} else {
    # Executa la comanda mvn amb els arguments
    $execArgs = @("-PrunMain", "-Dexec.mainClass=$mainClass", "-Djavafx.platform=$javafx_platform")
    Write-Output "Exec args: $($execArgs -join ' ')"

    # Executa la comanda mvn
    mvn clean test-compile exec:java $execArgs
}
```

Generar l'arxiu .jar

```bash
./run.sh com.project.Server build
ls -ltr target/*.jar
```

*(O amb .\run.sh com.project.Server build)*

Ha de llistar: target/server-package.jar

## Enviar el .jar al servidor

```bash
scp -i id_rsa -P 20127 ./server-package.jar apalaci8@ieticloudpro.ieti.cat:~/
```

## Fer anar el .jar al servidor

```bash
ssh -i ...
sudo ufw enable
sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 3000
sudo iptables -t nat -L -v -n
java -jar server-package.jar
```
