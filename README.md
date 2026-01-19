# Sombra Mobile

Flutter-клиент для голосового AI-ассистента Sombra.

## Фичи

- Голосовой ввод с push-to-talk
- Красивый Material 3 UI
- SSE стриминг ответов
- Тёмная тема

## Сборка

### Требования
- Flutter 3.16+
- Android SDK 24+

### Локальная сборка

```bash
flutter pub get
flutter build apk --debug
```

### CI/CD

Push тег для автоматической сборки:
```bash
git tag -a v0.1.0 -m "Release 0.1.0"
git push origin v0.1.0
```

APK появится в GitHub Releases.

### Подпись релиза

Для подписанной сборки добавь секреты в GitHub:
- `KEYSTORE_BASE64` — keystore в base64
- `KEYSTORE_PASSWORD`
- `KEY_ALIAS`
- `KEY_PASSWORD`

## Конфигурация

API URL настраивается в `lib/core/providers/providers.dart`:
```dart
final apiUrlProvider = StateProvider<String>((ref) {
  return 'http://90.156.230.49:8080';
});
```

## Структура

```
lib/
├── main.dart
├── core/
│   ├── api/          # Sombra API client
│   ├── providers/    # Riverpod providers
│   └── theme/        # App theme
├── features/
│   └── chat/
│       ├── domain/   # Models
│       └── presentation/
│           ├── screens/
│           ├── widgets/
│           └── providers/
└── shared/           # Shared widgets
```
