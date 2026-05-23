import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../domain/entities/create_device_request_input.dart';
import '../providers/device_requests_providers.dart';

class CreateDeviceRequestPage extends ConsumerStatefulWidget {
  const CreateDeviceRequestPage({super.key});

  @override
  ConsumerState<CreateDeviceRequestPage> createState() =>
      _CreateDeviceRequestPageState();
}

class _CreateDeviceRequestPageState
    extends ConsumerState<CreateDeviceRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createDeviceRequestControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('device_requests.create_title'.tr()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.viewInsetsOf(context).bottom + 24,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'device_requests.create_subtitle'.tr(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _brandController,
                      decoration: InputDecoration(
                        labelText: 'device_requests.brand_label'.tr(),
                      ),
                      validator: _required,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _modelController,
                      decoration: InputDecoration(
                        labelText: 'device_requests.model_label'.tr(),
                      ),
                      validator: _required,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'device_requests.notes_label'.tr(),
                      ),
                    ),
                    if (state.hasError) ...[
                      const SizedBox(height: 14),
                      Text(
                        state.errorMessage!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: state.isSubmitting ? null : _submit,
                        child: state.isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2.2),
                              )
                            : Text('device_requests.submit_cta'.tr()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _required(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return 'device_requests.field_required'.tr();
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final result = await ref
        .read(createDeviceRequestControllerProvider.notifier)
        .submit(
          CreateDeviceRequestInput(
            brand: _brandController.text.trim(),
            model: _modelController.text.trim(),
            notes: _notesController.text.trim(),
          ),
        );

    if (!mounted) {
      return;
    }

    switch (result) {
      case Success():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('device_requests.create_success'.tr())),
        );
        Navigator.of(context).pop();
      case Error():
        break;
    }
  }
}
