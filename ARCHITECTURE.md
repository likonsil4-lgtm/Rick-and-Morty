
Feature-first Clean Architecture

lib/
 core/
 features/
   characters/
     data/
     domain/
     presentation/

Flow:
UI -> Cubit -> UseCase -> Repository -> DataSource -> API
