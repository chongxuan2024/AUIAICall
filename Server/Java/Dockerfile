# 使用官方JDK镜像作为基础镜像
FROM openjdk:11-jre-slim

# 指定工作目录
WORKDIR /app

# 将打包的JAR文件复制到工作目录
COPY target/aui-ims-robot-0.0.1-SNAPSHOT.jar app.jar

# 暴露应用运行的端口
EXPOSE 8080

# 指定容器启动时执行的命令（运行JAR包）
ENTRYPOINT ["java", "-jar", "app.jar"]
