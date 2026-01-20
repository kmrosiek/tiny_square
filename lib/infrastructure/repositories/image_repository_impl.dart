import '../../domain/entities/random_image.dart';
import '../../domain/repositories/image_repository.dart';
import '../datasources/image_remote_datasource.dart';

class ImageRepositoryImpl implements ImageRepository {
  final ImageRemoteDataSource dataSource;

  ImageRepositoryImpl({required this.dataSource});

  @override
  Future<RandomImage> getRandomImage() async {
    return await dataSource.getRandomImage();
  }
}
