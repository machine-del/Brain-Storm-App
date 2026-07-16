import 'package:flutter/material.dart';

import '../../../../core/domain/entities/task_entity.dart';
import '../../../../core/domain/entities/answer_entity.dart';
import 'answer_options.dart';

class TaskCard extends StatefulWidget {
  final TaskEntity task;
  final Function(AnswerEntity) onAnswer;

  const TaskCard({
    super.key,
    required this.task,
    required this.onAnswer,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  int? _selectedIndex;
  final TextEditingController _freeTextController = TextEditingController();
  bool _isAnswered = false;
  int _startTime = 0;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now().millisecondsSinceEpoch;
  }

  @override
  void dispose() {
    _freeTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isAnswered) {
      return _buildSuccessScreen();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.task.hint != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb, color: Colors.amber),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '💡 ${widget.task.hint}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        Text(
          widget.task.instruction,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        if (widget.task.isFreeText) ...[
          _buildFreeTextInput(),
        ] else ...[
          AnswerOptions(
            options: widget.task.options,
            selectedIndex: _selectedIndex,
            onOptionSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _canSubmit() ? _submitAnswer : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Отправить ответ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFreeTextInput() {
    return TextField(
      controller: _freeTextController,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: 'Напиши свой ответ здесь...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.05),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  bool _canSubmit() {
    if (widget.task.isFreeText) {
      return _freeTextController.text.trim().isNotEmpty;
    }
    return _selectedIndex != null;
  }

  void _submitAnswer() {
    final timeSpent = (DateTime.now().millisecondsSinceEpoch - _startTime) ~/ 1000;

    final answer = AnswerEntity(
      taskId: widget.task.id,
      selectedIndex: _selectedIndex,
      selectedOption: _selectedIndex != null
          ? widget.task.options[_selectedIndex!]
          : null,
      freeTextAnswer: widget.task.isFreeText ? _freeTextController.text.trim() : null,
      timeSpentSeconds: timeSpent,
      isCorrect: false,
      skillType: widget.task.skillType,
    );

    setState(() {
      _isAnswered = true;
    });

    widget.onAnswer(answer);
  }

  Widget _buildSuccessScreen() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.withOpacity(0.1), Colors.blue.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Ответ отправлен!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Задание: ${widget.task.title}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          if (widget.task.explanation.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '📖 ${widget.task.explanation}',
                style: const TextStyle(fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }
}