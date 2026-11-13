import 'package:flutter/foundation.dart';

import '../../../core/network/api_result.dart';
import '../../../core/presentation/widgets/page_loader.dart';
import '../../../data/common/page_response.dart';
import '../../../data/dto/chat/chat_dtos.dart';
import '../../../data/repository/chat_repository.dart';

class ChatViewModel extends ChangeNotifier {
  ChatViewModel(this._repo) {
    loader.loadFirst();
  }

  final ChatRepository _repo;

  late final loader = PageLoader<ChatResponse>(_loadChats);

  Future<ApiResult<PageResponse<ChatResponse>>> _loadChats(int page) => _repo.list(page);

  @override
  void dispose() {
    loader.dispose();
    super.dispose();
  }
}
