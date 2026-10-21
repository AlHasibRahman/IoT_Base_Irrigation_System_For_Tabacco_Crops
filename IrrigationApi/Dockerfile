FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY ["IrrigationApi.csproj", "./"]
RUN dotnet restore "IrrigationApi.csproj"
COPY . .
RUN dotnet publish "IrrigationApi.csproj" -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app
COPY --from=build /app/publish .
ENV ASPNETCORE_ENVIRONMENT=Development
ENV ASPNETCORE_URLS=http://+:5000
EXPOSE 5000
USER app
ENTRYPOINT [ "dotnet", "IrrigationApi.dll" ]
