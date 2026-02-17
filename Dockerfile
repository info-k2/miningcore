# Шаг 1: Сборка (используем jammy, так как там нужные либы)
FROM mcr.microsoft.com/dotnet/sdk:6.0-jammy as BUILDER
WORKDIR /app

# Устанавливаем всё необходимое для компиляции алгоритмов (SHA-256/BCH)
RUN apt-get update && \
    apt-get -y install cmake build-essential libssl-dev pkg-config libboost-all-dev libsodium-dev libzmq5 libzmq3-dev golang-go

# Копируем ИСПРАВЛЕННЫЙ код из вашего GitHub (Portainer сам его сюда положит)
COPY . .

# Собираем ваш проект
WORKDIR /app/src/Miningcore
RUN dotnet publish -c Release --framework net6.0 -o /app/build

# Шаг 2: Финальный образ
FROM mcr.microsoft.com/dotnet/aspnet:6.0-jammy
WORKDIR /app

# Устанавливаем системные либы, без которых пул НЕ ЗАПУСТИТСЯ
RUN apt-get update && \
    apt-get install -y libzmq5 libzmq3-dev libsodium-dev curl openssl && \
    apt-get clean

# Копируем готовую сборку из первого шага
COPY --from=BUILDER /app/build ./

# Запуск
ENTRYPOINT ["dotnet", "Miningcore.dll", "-c", "config.json" ]
