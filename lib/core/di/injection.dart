import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import '../../application/image/image_cubit.dart';
import '../../domain/repositories/image_repository.dart';
import '../../domain/services/color_extractor.dart';
import '../../infrastructure/datasources/image_remote_datasource.dart';
import '../../infrastructure/repositories/image_repository_impl.dart';
import '../../infrastructure/services/color_extractor_impl.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt
    ..registerLazySingleton<http.Client>(http.Client.new)
    ..registerLazySingleton<ImageRemoteDataSource>(() => ImageRemoteDataSourceImpl(client: getIt<http.Client>()))
    ..registerLazySingleton<ImageRepository>(() => ImageRepositoryImpl(dataSource: getIt<ImageRemoteDataSource>()))
    ..registerLazySingleton<ColorExtractor>(ColorExtractorImpl.new)
    ..registerFactory<ImageCubit>(
      () => ImageCubit(repository: getIt<ImageRepository>(), colorExtractor: getIt<ColorExtractor>()),
    );
}
