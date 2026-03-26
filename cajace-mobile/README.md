# CAJACE Mobile

Aplicacion Flutter para CAJACE con arquitectura limpia, autenticacion contra el backend NestJS y base para notificaciones en tiempo real.

## Prerrequisitos

- Flutter 3.19 o superior
- Dart 3.3 o superior
- Android Studio
- JDK 17

## Ejecutar en emulador Android

1. Asegura que el backend este corriendo en el puerto `3000`.
2. Inicia un emulador Android.
3. Desde `D:\PROYECTOS\CAJACE\cajace-mobile`, ejecuta:

```bash
flutter run
```

## Ejecutar en dispositivo fisico

1. Habilita el modo desarrollador y la depuracion USB en el dispositivo.
2. Conecta el dispositivo y verifica que Flutter lo detecte.
3. Ejecuta `flutter run` desde `D:\PROYECTOS\CAJACE\cajace-mobile`.
4. Si usas un dispositivo fisico, actualiza la URL base del backend para que apunte a una IP accesible desde la red local.

## Notas de entorno

- El backend debe estar disponible en el puerto `3000`.
- Android emulator usa `http://10.0.2.2:3000`.
- iOS simulator usa `http://localhost:3000`.
- Agrega `google-services.json` antes de compilar con Firebase en Android.
