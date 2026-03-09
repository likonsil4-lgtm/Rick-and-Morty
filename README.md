# Rick and Morty Characters App

##  Функционал

### Основные возможности
- **Список персонажей** — бесконечная прокрутка (пагинация) с карточками персонажей
- **Избранное** — добавление/удаление персонажей с анимацией и сортировкой (по имени, статусу, виду)
- **Поиск и фильтрация** — поиск по имени, фильтры по статусу (Alive/Dead/Unknown) и полу
- **Офлайн-режим** — полная работа без интернета благодаря кешированию
- **Темная тема** — переключение между светлой и темной темой с анимацией

### Технические особенности
- **Архитектура**: Clean Architecture (Domain, Data, Presentation)
- **State Management**: Flutter BLoC (Cubit)
- **DI**: GetIt + Injectable
- **Локальное хранилище**: SQLite (избранное) + SharedPreferences (кеш персонажей и настройки темы)
- **Сеть**: Dio с обработкой ошибок и fallback на кеш
- **UI**: Material 3 с кастомными анимациями (Hero, staggered animations)

##  Сборка и запуск

### Требования
- **Flutter**: 3.0.0 или выше
- **Dart**: 3.0.0 или выше
- **Android**: minSdkVersion 21 (Android 5.0)
- **iOS**: iOS 11.0 или выше

## Зависимости

### Основные

| Пакет               | Версия | Назначение                          |
| ------------------- | ------ | ----------------------------------- |
| flutter\_bloc       | ^8.1.3 | State management (BLoC/Cubit)       |
| dio                 | ^5.4.0 | HTTP-клиент для работы с API        |
| sqflite             | ^2.3.0 | SQLite база данных для избранного   |
| shared\_preferences | ^2.2.2 | Локальное хранилище настроек и кеша |
| get\_it             | ^7.6.4 | Service Locator (DI)                |
| injectable          | ^2.3.2 | Code generation для DI              |

## UI и утилиты

| Пакет                         | Версия   | Назначение                      |
| ----------------------------- | -------- | ------------------------------- |
| cached\_network\_image        | ^3.3.0   | Кеширование изображений         |
| shimmer                       | ^3.0.0   | Skeleton-загрузка               |
| animations                    | ^2.0.11  | Кастомные анимации              |
| equatable                     | ^2.0.5   | Сравнение объектов              |
| internet\_connection\_checker | ^1.0.0+1 | Проверка подключения к сети     |
| dartz                         | ^0.10.1  | Функциональное программирование |

## Dev-зависимости

- **build_runner**: ^2.4.7 — генерация кода
- **injectable_generator**: ^2.4.1 — генерация DI
- **json_serializable**: ^6.7.1 — сериализация моделей
- **flutter_lints**: ^3.0.1 — линтинг

##  Структура проекта

    lib/
    ├── core/                    # Ядро приложения
    │   ├── constants/           # Константы (API URLs)
    │   ├── di/                  # Dependency Injection (get_it)
    │   ├── network/             # NetworkInfo, ApiClient
    │   └── theme/               # Темы приложения
    ├── data/                    # Слой данных
    │   ├── datasources/         # Источники данных
    │   │   ├── local/           # SQLite, SharedPreferences
    │   │   └── remote/          # REST API (Dio)
    │   ├── models/              # DTO-модели (json_serializable)
    │   └── repositories/        # Реализации репозиториев
    ├── domain/                  # Доменный слой
    │   ├── entities/            # Бизнес-сущности
    │   ├── repositories/        # Абстракции репозиториев
    │   └── usecases/            # Use cases (опционально)
    ├── presentation/            # UI-слой
    │   ├── blocs/               # BLoCs/Cubits
    │   ├── pages/               # Экраны
    │   └── widgets/             # Переиспользуемые виджеты
    └── main.dart                # Точка входа
