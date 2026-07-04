import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/ai_advisor_remote_data_source.dart';
import '../../data/repositories/ai_advisor_repository_impl.dart';
import '../../domain/entities/ai_advisor_result.dart';
import '../../domain/repositories/ai_advisor_repository.dart';
import '../../domain/usecases/ask_ai_advisor_use_case.dart';
import '../models/ai_advisor_state.dart';

final aiAdvisorRemoteDataSourceProvider = Provider<AiAdvisorRemoteDataSource>((
  ref,
) {
  return AiAdvisorRemoteDataSource(ref.watch(dioProvider));
});

final aiAdvisorRepositoryProvider = Provider<AiAdvisorRepository>((ref) {
  return AiAdvisorRepositoryImpl(
    networkHandler: ref.watch(networkHandlerProvider),
    remoteDataSource: ref.watch(aiAdvisorRemoteDataSourceProvider),
  );
});

final askAiAdvisorUseCaseProvider = Provider<AskAiAdvisorUseCase>((ref) {
  return AskAiAdvisorUseCase(ref.watch(aiAdvisorRepositoryProvider));
});

final aiAdvisorControllerProvider =
    NotifierProvider<AiAdvisorController, AiAdvisorState>(
      AiAdvisorController.new,
    );

class AiAdvisorController extends Notifier<AiAdvisorState> {
  AskAiAdvisorUseCase get _askAiAdvisorUseCase =>
      ref.read(askAiAdvisorUseCaseProvider);

  @override
  AiAdvisorState build() {
    return const AiAdvisorState.initial();
  }

  void setQuery(String query) {
    state = state.copyWith(query: query, clearFailure: true, clearError: true);
  }

  Future<void> submit() async {
    final query = state.query.trim();
    if (query.length < 2) {
      state = state.copyWith(
        errorMessage:
            'اكتب طلباً أو وصفاً أطول قليلاً لاقتراح الأجهزة المناسبة.',
      );
      return;
    }

    state = state.copyWith(
      query: query,
      isSubmitting: true,
      clearFailure: true,
      clearError: true,
    );

    final result = await _askAiAdvisorUseCase(query: query);

    switch (result) {
      case Success<AiAdvisorResult>(:final data):
        state = state.copyWith(isSubmitting: false, result: data);
      case Error<AiAdvisorResult>(:final failure):
        state = state.copyWith(
          isSubmitting: false,
          failure: failure,
          errorMessage: _mapFailure(failure),
        );
    }
  }

  String _mapFailure(Failure failure) {
    return switch (failure) {
      ValidationFailure() => failure.message,
      NetworkFailure() =>
        'تعذر الوصول إلى المساعد الذكي. تحقق من الاتصال ثم حاول مرة أخرى.',
      UnauthorizedFailure() => 'تعذر إكمال الطلب الحالي. حاول مرة أخرى.',
      ForbiddenFailure() => 'ليس لديك صلاحية للوصول إلى هذه الخدمة.',
      CacheFailure() => 'تعذر قراءة البيانات المحلية.',
      ServerFailure() => 'الخادم غير متاح حالياً. حاول لاحقاً.',
      UnknownFailure() =>
        failure.message.isEmpty
            ? 'حدث خطأ غير متوقع أثناء طلب الاقتراحات الذكية.'
            : failure.message,
    };
  }
}
