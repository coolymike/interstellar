import 'package:flutter/material.dart';
import 'package:interstellar/src/widgets/text_editor.dart';

Future<String?> reportContent(BuildContext context, String contentTypeName) =>
    showDialog<String>(
      context: context,
      builder: (BuildContext context) =>
          ReportContentBody(contentTypeName: contentTypeName),
    );

class ReportContentBody extends StatefulWidget {
  final String contentTypeName;

  const ReportContentBody({required this.contentTypeName, super.key});

  @override
  State<ReportContentBody> createState() => _ReportContentBodyState();
}

class _ReportContentBodyState extends State<ReportContentBody> {
  final _reasonTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Report ${widget.contentTypeName}'),
      content: TextEditor(
        _reasonTextEditingController,
        label: 'Reason',
        onChanged: (_) => setState(() {}),
      ),
      actions: <Widget>[
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _reasonTextEditingController.text.isEmpty
              ? null
              : () => Navigator.pop(context, _reasonTextEditingController.text),
          child: const Text('Report'),
        ),
      ],
      actionsOverflowAlignment: OverflowBarAlignment.center,
      actionsOverflowButtonSpacing: 8,
      actionsOverflowDirection: VerticalDirection.up,
    );
  }
}
