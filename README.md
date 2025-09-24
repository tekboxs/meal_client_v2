## Dart SDK version: 3.7.2
## 3.29.3

# 🍰 MealClient - Biblioteca HTTP Client para Flutter

> **Destaque Especial: Bolo de Fuba** 🥮
> 
> Esta biblioteca foi desenvolvida com o mesmo carinho e dedicação que se faz um bolo de fuba caseiro - ingredientes simples, mas que resultam em algo delicioso e funcional. Assim como o bolo de fuba é uma receita tradicional que nunca sai de moda, o MealClient oferece funcionalidades essenciais e confiáveis para suas aplicações Flutter.

## 📋 Sobre

O **MealClient** é uma biblioteca Flutter robusta e elegante para gerenciamento de requisições HTTP, autenticação automática e cache inteligente. Desenvolvida com foco em simplicidade e performance, ela oferece todas as funcionalidades essenciais para integração com APIs REST.

## ✨ Funcionalidades Principais

### 🔐 Autenticação Automática
- **Gerenciamento de JWT**: Renovação automática de tokens
- **Interceptadores inteligentes**: Adição automática de headers de autorização
- **Fallback de credenciais**: Sistema de backup para casos de erro
- **Validação de expiração**: Verificação automática de validade dos tokens

### 🔐 Cliente HTTP Robusto
- **Métodos HTTP completos**: GET, POST, PUT, DELETE
- **Suporte a URLs absolutas e relativas**
- **Headers customizáveis**
- **Tratamento de erros inteligente**
- **Retry automático em falhas**

### 💾 Sistema de Cache Avançado
- **Cache em memória**: Armazenamento local usando Hive
- **Work Memory**: Cache temporário para sessões ativas
- **Long Term Memory**: Persistência de dados importantes
- **Fallback inteligente**: Retorna dados do cache em caso de erro de rede

### 🗄️ Gerenciamento de Dados
- **Hive Integration**: Armazenamento local eficiente
- **Chaves tipadas**: Sistema de enum para chaves de configuração
- **Serviços especializados**: Para dados primitivos e objetos complexos
- **Operações CRUD**: Create, Read, Update, Delete simplificados

## 🚀 Instalação

Adicione a dependência no seu `pubspec.yaml`:

```yaml
dependencies:
  meal_client:
    git:
      url: https://github.com/tekboxs/meal_client
      ref: 1.0.0
```

## 📖 Uso Básico

### Configuração Inicial

```dart
import 'package:meal_client/meal_client.dart';

// Configurar credenciais
await ClientKeys.baseUrl.write('https://api.exemplo.com');
await ClientKeys.usuario.write('seu_usuario');
await ClientKeys.senha.write('sua_senha');
await ClientKeys.conta.write('sua_conta');
```

### Fazendo Requisições

```dart
// Instanciar o cliente
final client = AppClientProvider(httpClient);

// GET request
final produtos = await '/estoque/produto'.get();

// POST request
final resultado = await '/estoque/produto'.post(
  KRequestOptions(dataToSend: {"bolo": "fuba"})
);

// PUT request
final resultado = await '/estoque/produto'.put(
  KRequestOptions(dataToSend: {"bolo": "fuba"})
);

// DELETE request
await '/estoque/produto/123'.delete();
```

### Usando Cache Inteligente

```dart
// Com cache habilitado (padrão)
final dados = await '/dados'.get(
  KRequestOptions(enableWorkMemory: true)
);

// Sem cache
final dados = await '/dados'.get(
  KRequestOptions(enableWorkMemory: true)
);
```

## 🏗️ Arquitetura

### Componentes Principais

- **`AppClientProvider`**: Cliente HTTP principal com métodos CRUD
- **`APIAuthenticator`**: Gerenciamento de autenticação e tokens
- **`APIClientInterceptors`**: Interceptadores para headers e tratamento de erros
- **`ClientKeys`**: Enum para chaves de configuração
- **`HiveSimpleClientService`**: Serviço para dados primitivos
- **`HiveCustomClientService`**: Serviço para objetos complexos

### Fluxo de Autenticação

1. **Verificação de token existente**
2. **Validação de expiração**
3. **Renovação automática se necessário**
4. **Fallback para credenciais padrão em caso de erro**

## 🧪 Testes

A biblioteca inclui uma suíte completa de testes:

```bash
flutter test
```

### Exemplos de Teste

Consulte `/test/client_test.dart` para exemplos práticos de uso.

## 🔧 Configurações Avançadas

### Headers Customizados

```dart
final resultado = await  '/endpoint'.get(
    KRequestOptions(
      headers: {'Custom-Header': 'valor'}
    )
  );
```

### Desabilitar Token Automático

```dart
final resultado = await  '/endpoint'.get(
    KRequestOptions(disableAutoToken: true)
  );
```

### Chave de Exportação Customizada

```dart
final dados = await '/endpoint'.get(
  KRequestOptions(
   exportKey: 'resultado', // Padrão: 'data'
  )
);
```

## 🎯 Casos de Uso

- **Aplicações de e-commerce**: Gerenciamento de produtos e estoque
- **Sistemas de autenticação**: Login e controle de sessão
- **APIs de terceiros**: Integração com serviços externos
- **Aplicações offline-first**: Cache inteligente para funcionamento offline

## 🤝 Contribuição

Contribuições são bem-vindas! Sinta-se à vontade para:

1. Reportar bugs
2. Sugerir novas funcionalidades
3. Enviar pull requests
4. Melhorar a documentação

## Licença

Este projeto está sob a licença MIT. Veja o arquivo LICENSE para mais detalhes.

## 🍰 Sobre o Bolo de Fuba

Assim como um bom bolo de fuba, esta biblioteca foi feita com ingredientes simples mas essenciais:
- **Simplicidade**: Interface limpa e intuitiva
- **Confiabilidade**: Funciona sempre, como uma receita testada
- **Sabor**: Experiência de desenvolvimento agradável
- **Tradição**: Baseada em padrões consagrados do Flutter

*"Código bom é como bolo de fuba: simples, gostoso e sempre funciona!"* 🥮

---
