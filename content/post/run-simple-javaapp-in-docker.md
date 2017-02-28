+++
Description = "Example of Simple Java App run in Docker Container"
Tags = [
  "java", 
  "maven"
]
Categories = [
  "java"
]
date = "2017-02-28T11:30:52-03:00"
title = "Run simple Java App in Docker container"

+++

## Steps

1. build maven project;
2. create file (Dockerfile) in project root directory;
3. create file (start.sh) in project root directory;
4. write "{package}.Main.java"
5. configure "Dockerfile"
6. add commands in "start.sh" file
7. test


## Writing App

Create a package named "ag.pod.helloworld" or as you think best. This package must be used in _pom.xml_ to define Main-Class in META-INF/MANIFEST.MF by Assembly Maven Plugin.

```
package ag.pod.helloworld;

public class Main {

	public static void main(String[] args) {
		System.out.println("Hello World");
	}
}

```

For now "Hello World" is enough.



## Writing Dockerfile

_Dockerfile_ must be configurated for maven + openjdk-8 container from "maven:3.3.9-jdk-8" image.
In container the app will be in path "/opt/app". The shared volume will be "/opt/shared".

```
FROM maven:3.3.9-jdk-8

ADD . /opt/app
RUN cd /opt/app && mvn compile package -DskipTests=true
RUN chmod +x /opt/app/start.sh

CMD /opt/app/start.sh
```

Build docker image will take several minutes, so you must be patient!




## Writing start.sh

_start.sh_ contain command line for run app in docker container. There is no secret! 

```
#/bin/bash
java -jar /opt/app/target/PODApp-jar-with-dependencies.jar

```

or 

```
#/bin/bash
java -cp /opt/app/target/PODApp.jar ag.pod.helloworld.Main

```

_PODApp-jar-with-dependencies.jar_ is builded on execute “mvn package”. For this _pom.xml_ must contain configurated assembly-maven-plugin like bellow:

```
<plugin>
  <artifactId>maven-assembly-plugin</artifactId>
  <version>3.0.0</version>
  <configuration>
    <descriptorRefs>
      <descriptorRef>jar-with-dependencies</descriptorRef>
    </descriptorRefs>
    <archive>
      <manifest>
      	<!-- change package name here -->
        <mainClass>ag.pod.helloworld.Main</mainClass>
      </manifest>
    </archive>
  </configuration>
  <executions>
    <execution>
      <id>make-assembly</id>
      <phase>package</phase>
      <goals>
        <goal>single</goal>
      </goals>
    </execution>
  </executions>
</plugin>
```
Note that the jar name is "PODApp.jar". It is defined in the build tag on _pom.xml_:

```
<build>
  <finalName>PODApp</finalName>
  <plugins>
    ...
  </plugins>
</build>  
```

On execute package goal maven compile, package and generate two jar files:
 i) {app_name}.jar and
ii) {app_name}-jar-with-dependencies.jar

The first jar contain no manifest file, so it will run using class-path and class-main. For instance: ` java -cp /opt/app/target/PODApp.jar ag.pod.helloworld.Main `. 

The last jar contain manifest file with defined Class-Main and all embedded dependencies. In this case, to run use ` java -jar /opt/app/target/PODApp-jar-with-dependencies.jar `.


## Testing

Split test in two parts. The first for check app in a docker container and second to check shared directory.

### Checking app in container

Execute in command line the stament bellow to build docker image in project root directory using the template: `docker build --tag=pod:<version> <dockerfile path>`.

```
  $ docker build --tag=pod:1.0.0 .
```

After build list images using `docker images` command. The result will be anything like:
```
  $ docker images
  ...
  REPOSITORY     TAG             IMAGE ID       CREATED       SIZE
  pod            1.0.0           c7cf438420c2   2 weeks ago   651.5 MB
  maven          3.3.9-jdk-8     14f4340d04cb   2 weeks ago   651.5 MB
  ...

```

The next step is to create and run two containers. After run you must check containers logs. 

```
  $ docker run -d -p 10999:10999 -v /tmp:/opt/shared -t pod:1.0.0 ls /opt/shared
  $ docker run -d -p 10998:10998 -v /tmp:/opt/shared -t pod:1.0.0 ls /opt/shared
```

To check by log use `docker logs <containerId>`. You obtain container id by `docker ps -a` command. 

```
  $ docker ps -a
  ...
  CONTAINER ID        IMAGE         COMMAND                  CREATED
  783c8b7b2759        pod:1.0.0     "/usr/local/bin/mvn-e"   4 minutes ago
  24566245756a        pod:1.0.0     "/usr/local/bin/mvn-e"   4 minutes ago
  ...

  $ docker logs 783c8b7b2759
  ...
  sum.txt             diff.txt
  ...

  $ docker logs 24566245756a
  ...
  sum.txt             diff.txt
  ...

```

### Checking IO in shared directory

Replace last line in Dockerfile by `CMD touch /opt/shared/sum.txt && touch /opt/shared/diff.txt && /opt/app/start.sh`. It will create two files in /opt/shared path that can be checked by code:

```
  public static void main(String[] args) throws IOException {
	...
	//check sum.txt
	File sum_file = new File("/opt/shared/sum.txt");
	if (sum_file.exists()){
		System.out.println("Can write: " + sum_file.canWrite());
		System.out.println("Can read: " + sum_file.canRead());
	}
	else {
		System.out.println("Sum file not found");
	}
	
	//check diff.txt
	File diff_file = new File("/opt/shared/diff.txt");
	if (diff_file.exists()){
		System.out.println("Can write: " + diff_file.canWrite());
		System.out.println("Can read: " + diff_file.canRead());
	}
	else {
		System.out.println("Diff file not found");
	}
	...
  }
```

The result must be similar to:

```
  $ docker logs 783c8b7b2759
  Hello World
  Can write: true
  Can read: true
  Can write: true
  Can read: true
```

## References

- Assembly Maven Plugin: https://maven.apache.org/plugins/maven-assembly-plugin/usage.html
- Docker Image: https://hub.docker.com/_/maven/
- Share Directories: http://devopslab.com.br/docker-como-montar-uma-pasta-do-host-docker-dentro-de-um-container/

## Source Code

https://github.com/ag-ifpb/pod-codigos-20162/tree/master/ag.pod.helloworld









