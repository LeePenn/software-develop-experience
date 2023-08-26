### Dockerfile指令

基本指令格式：

```
# Comment
INSTRUCTION arguments
```
Dockerfile 不区分大小写，但是为了与参数区分，推荐大写
执行顺序为顺序，第一条指令必须为FROM
基本指令：
FROM、MAINTAINER、RUN、CMD、EXPOSE、ENV、ADD、COPY、ENTRYPOINT、VOLUME、USER、WORKDIR、ONBUILD

### LABEL

了解对象标签。你可以给镜像添加标签（LABEL），如记录许可信息，帮助自动化或其他信息。对象标签以键值对的形式出现，如果包含空格请用 " 扩起来。标签对象必须唯一，否则后者会覆盖前者。键可以包含 .、-、a-zA-Z、0-9。

例子：
```
# Set one or more individual labels
LABEL com.example.version="0.0.1-beta"
LABEL vendor="ACME Incorporated"
LABEL com.example.release-date="2015-02-12"
LABEL com.example.version.is-production=""

# Set multiple labels on one line
LABEL com.example.version="0.0.1-beta" com.example.release-date="2015-02-12"

# Set multiple labels at once, using line-continuation characters to break long lines
LABEL vendor=ACME\ Incorporated \
      com.example.is-beta= \
      com.example.is-production="" \
      com.example.version="0.0.1-beta" \
      com.example.release-date="2015-02-12"
```

### FROM

``` 
FROM <image>/<image>:<tag>
```
多个FROM会构建多个镜像，tag默认latest

### ENV

```
ENV <key> <value> / <key>=<value>
```
声明环境变量，会被后面的特定指令使用，ENV、ADD、COPY、WORKDIR、EXPOSE、VOLUME、USER

### COPY

```
COPY <src> <dest>
```

src可以为多个，此时dest必须是目录，如不存在，会被创建，/结尾说明指向的是目录

### ADD

```
ADD <src> <dest>
```

功能和COPY相似，但是还支持其他功能，src可以指向网络文件URL，还可以执行本地压缩文件，此时文件会被复制到容器解压提取，一般推荐使用COPY，因为COPY功能单一，只支持本地文件，功能透明，explicit better than implicit

### EXPOSE

```
EXPOSE <port> [<port>/<protocol>...]
```

暴露端口，可以指定端口是TCP还是UDP，未指定时默认TCP
该指令仅仅声明容器打算使用什么端口而已，并不会自动做端口映射

### USER

```
USER <user>[:<group>] / <UID>[:<GID>]
```

指定user name 和 user group，之后的RUN、CMD、ENTRYPOINT指令会以设置的user来执行

### WORKDIR

```
WORKDIR /path/to/workdir
```

设置工作目录，之后的RUN、CMD、ENTRYPOINT、COPY和ADD都会在这个工作目录下运行，如果不存在，会创建
如果有多个WORKDIR，之后的每个会以上一个WORKDIR为相对路径

```
# output /a/b/c
WORKDIR /a
WORKDIR b
WORKDIR c
RUN pwd
```

### RUN

```
RUN <command> (shell)
RUN ["executable", "param1", "param2"] (exec 格式，推荐使用)
```
shell格式，命令通过/bin/sh -c 运行
exec格式，命令会直接运行，不调用shell程序
会在创建出的镜像中创建一个容器，并在容器中运行命令，exec格式中的参数会被当成JSON数组被Docker解析，故必须使用双引号而不能使用单引号，因为exec格式不会在shell中执行，所以环境变量的参数不会被替换

### CMD

```
CMD <command> (shell)
CMD ["executable", "param1", "param2"] (exec)
CMD ["param1", "param2"] (为ENTRYPOINT提供参数)
```

Dockerfile中可以有多条CMD，但只有最后一条有效
与RUN不同的是，RUN在构建镜像时，执行命令，生成新镜像，CMD构建镜像时不执行命令，而是在启动时默认将CMD作为第一条指令运行
如果在docker run命令时指定了命令参数，会覆盖CMD的命令

### ENTRYPOINT

```
ENTRYPOINT <command> (shell)
ENTRYPOINT ["executable", "param1", "param2"] (exec)
```

多条ENTRYPOINT以最后一条有效 使用shell模式时，会忽略任何CMD指令和docker run命令的参数，这意味着ENTRYPOINT指令进程为bin/sh -c的子进程,进程在容器中的PID将不是1，且不能接受Unix信号。即当使用docker stop <container>命令时，命令进程接收不到SIGTERM信号。
推荐exec格式，docker run传入的参数会覆盖CMD指令并附加到ENTRYPOINT指令的参数中，CMD可以为参数，也可以为命令，EXTRYPOINT只能为命令，CMD可以被覆盖，ENTRYPOINT不能

### ONBUILD

ONBUILD 指令在当前 Dockerfile 构建完成后执行，存储到镜像 的manifest 清单中，我们可以通过 docker inspect 查看 OnBuild 的信息。

当我们使用带有 ONBUILD 触发器的镜像作为基础镜像来创建新镜像时，当 Dockerfile 执行到 FROM 时会自动查找 OnBuild 信息并执行这个触发器命令。成功后继续向下执行下一条指令，失败的话就停止向下执行并中止创建过程。如果成功创建了新的镜像后，这个新镜像中不会继承基础镜像中的 ONBUILD 触发器内容。参考 Ruby’s ONBUILD variants。

建立的图像 ONBUILD 应该有一个单独的标签，例如：ruby:1.9-onbuild 或 ruby:2.0-onbuild。

当把 ADD 或 COPY 加入 ONBUILD 中时要小心，如果新创建镜像的上下文缺少这些要添加的资源情况会导致创建的失败。因而添加单独的标签可以帮助我们减小这种情况发生的可能， 让 Dockerfile 作者来做决定。

### Dockerfile心得

#### 使用tag

#### 基础镜像

镜像大小关系：

busybox < debian < centos < ubuntu

只安装和更新必须使用的包，控制镜像大小，推荐使用Debian，非常轻量级，不过在实际开发中，应该用到 alpine 的次数比较多，因为它仅 5mb 左右。

#### 充分利用缓存

尽量将所有Dockerfile文件相同的部分都放在前面，而将不同的部分放到后面。

#### 正确使用ADD和COPY

当在Dockerfile中的不同部分需要用到不同的文件时，不要一次性地将这些文件都添加到镜像中去，而是在需要时添加，这样也有利于重复利用docker缓存。
另外考虑到镜像大小问题，使用ADD指令去获取远程URL中的压缩包不是推荐的做法。应该使用RUN wget或RUN curl代替。这样可以删除解压后不在需要的文件，并且不需要在镜像中在添加一层。

错误做法：

```
ADD http://example.com/big.tar.xz /usr/src/things/
RUN tar -xJf /usr/src/things/big.tar.xz -C /usr/src/things
RUN make -C /usr/src/things all
```

正确做法：

```
RUN mkdir -p /usr/src/things \
    && curl -SL http://example.com/big.tar.xz \
    | tar -xJC /usr/src/things \
    && make -C /usr/src/things all
```

#### RUN指令

在使用较长的RUN指令时可以使用反斜杠\分隔多行。大部分使用RUN指令的常见是运行apt-wget命令，在该场景下请注意以下几点。

1. 不要在一行中单独使用指令RUN apt-get update。当软件源更新后，这样做会引起缓存问题，导致RUN apt-get install指令运行失败。所以,RUN apt-get update和RUN apt-get install应该写在同一行。比如 RUN apt-get update && apt-get install -y package-1 package-2 package-3

2. 避免使用指令RUN apt-get upgrade 和 RUN apt-get dist-upgrade。因为在一个无特权的容器中，一些必要的包会更新失败。如果需要更新一个包(如package-1)，直接使用命令RUN apt-get install -y package-1。

#### CMD和ENTRYPOINT命令

推荐二者结合使用

```
FROM busybox
WORKDIR /app
COPY run.sh /app
RUN chmod +x run.sh
ENTRYPOINT ["/app/run.sh"]
CMD ["param1"]
```

run.sh内容如下：

```
#!/bin/sh
echo "$@"
```
运行后输出结果为param1, Dockerfile中CMD和ENTRYPOINT的顺序不重要(CMD写在ENTRYPOINT前后都可以)。

#### 不要再Dockerfile中做端口映射

使用Dockerfile的EXPOSE指令，虽然可以将容器端口映射在主机端口上，但会破坏Docker的可移植性，且这样的镜像在一台主机上只能启动一个容器。所以端口映射应在docker run命令中用-p 参数指定。

推荐如下写法：

```
# 不要再Dockerfile中做如下映射
EXPOSE 80:8080

# 仅暴露80端口,需要另做映射
EXPOSE 80
```

#### 编写优雅的Dockerfile主要需要注意以下几点：

1. Dockerfile文件不宜过长，层级越多最终制作出来的镜像也就越大。
2. 构建出来的镜像不要包含不需要的内容，如日志、安装临时文件等。
3. 尽量使用运行时的基础镜像，不需要将构建时的过程也放到运行时的Dockerfile里。

```
FROM ubuntu:16.04
RUN apt-get update
RUN apt-get install -y apt-utils libjpeg-dev \     
python-pip
RUN pip install --upgrade pip
RUN easy_install -U setuptools
RUN apt-get clean
FROM ubuntu:16.04
RUN apt-get update && apt-get install -y apt-utils \
  libjpeg-dev python-pip \
           && pip install --upgrade pip \
      && easy_install -U setuptools \
    && apt-get clean
```
Dockerfile把所有的组件全部在一层解决，这样做能一定程度上减少镜像的占用空间，但在制作基础镜像的时候若其中某个组编译出错，修正后再次Build就相当于重头再来了，前面编译好的组件在一个层里，得全部都重新编译一遍，比较消耗时间。
Dockerfile非常长的话可以考虑减少层次，因为Dockerfile最高只能有127层。

#### Docker 官方提供了一些建议和准则，在大多数情况下建议遵守。

1. 容器是短暂的，也就是说，你需要可以容易的创建、销毁、配置你的容器。
2. 多数情况，构建镜像的时候是将 Dockerfile 和所需文件放在同一文件夹下。但为了构建性能，我们可以采用 .dockerignore 文件来排除文件和目录。
3. 避免安装不必要的包，构建镜像应该尽可能减少复杂性、依赖关系、构建时间及镜像大小。
4. 最小化层数。
5. 排序多行参数，通过字母将参数排序来缓解以后的变化，这将帮你避免重复的包、使列表更容易更新，
如：

```
RUN apt-get update && apt-get install -y \
  bzr \
  cvs \
  git \
  mercurial \
  subversion
```
6. 构建缓存，大家知道 Docker 构建镜像的过程是顺序执行 Dockerfile 每个指令的过程。执行过程中，Docker 将在缓存中查找可重用的镜像，如果不想使用缓存，你也可以使用 docker build --no-cache=true ... 命令。

如果使用缓存，docker 将使用一下基本规则：

1. 从第一条指令开始，它将比较从基础镜像导出的所有子镜像，查看是否有相同的的构建指令，以此来获取缓存。
2. 在大多数情况下，简单地比较 Dockerfile 与其中一个子镜像的指令是足够的。但是，某些说明需要更多的检查和解释。
3. 对于 ADD 和 COPY 指令，会去比较文件的校验和，但不考虑文件的修改时间和访问时间。如果有任何变化，缓存无效。
4. 除了 ADD 和 COPY 指令，缓存检查不会查看容器中的文件来确定缓存匹配。例如，当处理 RUN apt-get -y update 命令时，将不会检查在容器中更新的文件以确定是否存在高速缓存命中。在这种情况下，只需使用命令字符串本身来查找匹配。
一旦缓存无效，所有后续 Dockerfile 命令将生成新的映像，并且高速缓存将不被使用。

#### APT-GET

使用 apt-get 你可以安装软件包，但这里有一些需要注意的地方。

您应该避免 RUN apt-get upgrade 或者 dist-upgrade，如果你需要更新软件包，使用 apt-get install -y foo 命令将会自动更新。

你应该将 RUN apt-get update 和 apt-get install 结合使用：

```
RUN apt-get update && apt-get install -y \
    package-bar \
    package-baz \
    package-foo
```
如果单独使用，会导致缓存失效或后续 apt-get install 指令失败，如：

```
FROM ubuntu:14.04
RUN apt-get update
RUN apt-get install -y curl
```    
第一执行构建该镜像是没问题的。可是当你第二次构建，Docker 会将 RUN apt-get update 看作是与镜像一是同一指令，会命中缓存。导致结果就是，你可能会安装一些过时的软件包。所以，使用 RUN apt-get update && apt-get install -y 能够破解缓存机制，实现清除缓存的结果。

下面是一个使用 apt-get 的指导建议：

```
RUN apt-get update && apt-get install -y \
    aufs-tools \
    automake \
    build-essential \
    curl \
    dpkg-sig \
    libcap-dev \
    libsqlite3-dev \
    mercurial \
    reprepro \
    ruby1.9.1 \
    ruby1.9.1-dev \
    s3cmd=1.1.* \
 && rm -rf /var/lib/apt/lists/*
```

#### USING PIPES

在 RUN 指令中使用 | 会有什么问题，Docker 只关注最后一个命令执行的正确与否，如：

```
RUN wget -O - https://some.site | wc -l > /number
```
即使 wget 失败，wc 成功也会成功构建镜像。

所以，如果想要执行过程中产生任何错误都失败，需要使用到 set -o pipefail &&。如：

```
RUN set -o pipefail && wget -O - https://some.site | wc -l > /number
```

#### 多阶段构建

Docker在升级到Docker 17.05之后就能支持多阶构建了，为了使镜像更加小巧，我们采用多阶构建的方式来打包镜像。在多阶构建出现之前我们通常使用一个Dockerfile或多个Dockerfile来构建镜像。

单文件构建例子：

```
FROM golang:1.11.4-alpine3.8 AS build-env
ENV GO111MODULE=off
ENV GO15VENDOREXPERIMENT=1
ENV BUILDPATH=github.com/lattecake/hello
RUN mkdir -p /go/src/${BUILDPATH}
COPY ./ /go/src/${BUILDPATH}
RUN cd /go/src/${BUILDPATH} && CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go install –v

CMD [/go/bin/hello]
```
存在的问题：

1. Dockerfile文件会特别长，当需要的东西越来越多的时候可维护性指数级将会下降；
2. 镜像层次过多，镜像的体积会逐步增大，部署也会变得越来越慢；
3. 代码存在泄漏风险。

以Golang为例，它运行时不依赖任何环境，只需要有一个编译环境，那这个编译环境在实际运行时是没有任务作用的，编译完成后，那些源码和编译器已经没有任务用处了也就没必要留在镜像里。

前端的两阶段构建：

```
FROM node:alpine as builder
WORKDIR '/build'
COPY myaccount ./myaccount
COPY resources ./resources
COPY third_party ./third_party

WORKDIR '/build/myaccount'

RUN npm install
RUN npm rebuild node-sass
RUN npm run build

RUN ls /build/myaccount/dist

FROM nginx
EXPOSE 80
# 需要注意结尾的 --from=builder这里和开头是遥相呼应的。
COPY --from=builder /build/myaccount/dist /usr/share/nginx/html
```

golang的多阶段构建例子：

```
FROM golang:1.11.4-alpine3.8 AS build-env
 
ENV GO111MODULE=off
ENV GO15VENDOREXPERIMENT=1
ENV GITPATH=github.com/lattecake/hello
RUN mkdir -p /go/src/${GITPATH}
COPY ./ /go/src/${GITPATH}
RUN cd /go/src/${GITPATH} && CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go install -v
 
FROM alpine:latest
ENV apk –no-cache add ca-certificates
COPY --from=build-env /go/bin/hello /root/hello
WORKDIR /root
CMD ["/root/hello"]
```

多文件构建，其实就是使用多个Dockerfile，然后通过脚本将它们进行组合。假设有三个文件分别是：Dockerfile.run、Dockerfile.build、build.sh。

1. Dockerfile.run就是运行时程序所必须需要的一些组件的Dockerfile，它包含了最精简的库；
2. Dockerfile.build只是用来构建，构建完就没用了；
3. build.sh的功能就是将Dockerfile.run和Dockerfile.build进行组成，把Dockerfile.build构建好的东西拿出来，然后再执行Dockerfile.run，算是一个调度的角色。

例子：

Dockerfile.build

```
FROM golang:1.11.4-alpine3.8 AS build-env
ENV GO111MODULE=off
ENV GO15VENDOREXPERIMENT=1
ENV BUILDPATH=github.com/lattecake/hello
RUN mkdir -p /go/src/${BUILDPATH}
COPY ./ /go/src/${BUILDPATH}
RUN cd /go/src/${BUILDPATH} && CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go install –v
```

Dockerfile.run

```
FROM alpine:latest
RUN apk –no-cache add ca-certificates
WORKDIR /root
ADD hello .
CMD ["./hello"]
```

Build.sh

```
#!/bin/sh
docker build -t –rm hello:build . -f Dockerfile.build
docker create –name extract hello:build
docker cp extract:/go/bin/hello ./hello
docker rm -f extract
docker build –no-cache -t –rm hello:run . -f Dockerfile.run
rm -rf ./hello
```