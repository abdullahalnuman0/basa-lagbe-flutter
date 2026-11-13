import 'package:flutter/foundation.dart';

import '../../../core/network/api_result.dart';
import '../../../core/presentation/widgets/page_loader.dart';
import '../../../core/utils/app_properties.dart';
import '../../../data/common/page_response.dart';
import '../../../data/dto/property/property_dtos.dart';
import '../../../data/repository/property_repository.dart';

class ListingsViewModel extends ChangeNotifier {
  ListingsViewModel(this._propertyRepo) {
    properties.loadFirst();
  }

  final PropertyRepository _propertyRepo;

  late final properties = PageLoader<PropertyResponse>(_loadProperty);

  Future<ApiResult<PageResponse<PropertyResponse>>> _loadProperty(int page) {
    final params = {'page': '$page', 'size': '${AppProperties.feedPageSize}'};
    return _propertyRepo.findPage(params);
  }

  @override
  void dispose() {
    properties.dispose();
    super.dispose();
  }
}
