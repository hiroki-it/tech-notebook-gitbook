# manifest.yml

## はじめに

本サイトにつきまして、以下をご認識のほど宜しくお願いいたします。

参考：https://hiroki-it.github.io/tech-notebook-gitbook/

<br>

## 01. spec

### specとは

参考：https://kubernetes.io/ja/docs/concepts/overview/working-with-objects/kubernetes-objects/

<br>

### apiVersion

```yaml
apiVersion: v1
```

<br>

### kind

```yaml
kind: Service
```

<br>

### metadata

#### ・name

```yaml
metadata:
  name: foo-service
```

<br>

### selector

#### ・app

```yaml
spec:
  selector:
    app: MyApp
```

<br>

### ports

リクエストの受信プロトコルを設定する。

#### ・protocol

```yaml
spec:
  ports:
  - protocol: TCP
```

#### ・port

リクエストの受信ポートを設定する。

```yaml
spec:
  ports:
  - port: 80
```

####  ・targetPort

リクエストの転送先ポートを設定する。

```yaml
spec:
  ports:
  - targetPort: 9376
```

<br>

### template

```yaml
spec:
  template: # Pod
    spec:
      containers:
      - name: hello # Pod内コンテナ名
        image: busybox # イメージ
        command: ['sh', '-c', 'echo "Hello, Kubernetes!" && sleep 3600'] # コンテナ起動時コマンド
      restartPolicy: OnFailure
```

