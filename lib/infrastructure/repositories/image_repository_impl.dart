import '../../domain/entities/random_image.dart';
import '../../domain/repositories/image_repository.dart';
import '../datasources/image_remote_datasource.dart';

class ImageRepositoryImpl implements ImageRepository {
  ImageRepositoryImpl({required this.dataSource});
  final ImageRemoteDataSource dataSource;

  @override
  Future<RandomImage> getRandomImage() => dataSource.getRandomImage();
}
