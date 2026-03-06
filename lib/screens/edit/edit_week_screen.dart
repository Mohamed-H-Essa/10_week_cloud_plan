import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/task_item.dart';
import '../../providers/study_plan_provider.dart';
import '../../shared/constants/phase_colors.dart';

class EditWeekScreen extends ConsumerStatefulWidget {
  final int weekNumber;
  const EditWeekScreen({super.key, required this.weekNumber});

  @override
  ConsumerState<EditWeekScreen> createState() => _EditWeekScreenState();
}

class _EditWeekScreenState extends ConsumerState<EditWeekScreen> {
  late List<TaskItem> _fridayTasks;
  late List<TaskItem> _saturdayTasks;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final plans = ref.read(weekPlansProvider);
    final plan = plans.firstWhere((p) => p.weekNumber == widget.weekNumber);
    _fridayTasks = plan.fridayTasks.map((t) => t.copyWith()).toList();
    _saturdayTasks = plan.saturdayTasks.map((t) => t.copyWith()).toList();
  }

  void _markChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  Future<void> _save() async {
    // Reindex sort orders
    for (int i = 0; i < _fridayTasks.length; i++) {
      _fridayTasks[i].sortOrder = i;
    }
    for (int i = 0; i < _saturdayTasks.length; i++) {
      _saturdayTasks[i].sortOrder = i;
    }
    await ref
        .read(weekPlansProvider.notifier)
        .updateTasks(widget.weekNumber, _fridayTasks, _saturdayTasks);
    if (mounted) Navigator.pop(context);
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('You have unsaved changes that will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _addTask(String day) {
    final task = TaskItem(
      id: const Uuid().v4(),
      text: '',
      day: day,
      isCustom: true,
      sortOrder: day == 'friday' ? _fridayTasks.length : _saturdayTasks.length,
    );
    setState(() {
      if (day == 'friday') {
        _fridayTasks.add(task);
      } else {
        _saturdayTasks.add(task);
      }
    });
    _markChanged();
  }

  void _deleteTask(String day, int index) {
    setState(() {
      if (day == 'friday') {
        _fridayTasks.removeAt(index);
      } else {
        _saturdayTasks.removeAt(index);
      }
    });
    _markChanged();
  }

  void _moveTaskToWeek(TaskItem task, String day, int index) {
    final plans = ref.read(weekPlansProvider);
    final weekOptions = plans
        .where((p) => p.weekNumber != widget.weekNumber)
        .map((p) => p.weekNumber)
        .toList();

    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Move to week'),
        actions: weekOptions
            .map(
              (w) => CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  // Remove from current
                  setState(() {
                    if (day == 'friday') {
                      _fridayTasks.removeAt(index);
                    } else {
                      _saturdayTasks.removeAt(index);
                    }
                  });
                  _markChanged();
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(
                      content: Text('Task will move to Week $w after save'),
                    ),
                  );
                },
                child: Text('Week $w'),
              ),
            )
            .toList(),
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plans = ref.watch(weekPlansProvider);
    final plan = plans.firstWhere((p) => p.weekNumber == widget.weekNumber);
    final colors = getPhaseColors(plan.phase, Theme.of(context).brightness)!;

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Edit Week ${widget.weekNumber}',
            style: GoogleFonts.jetBrainsMono(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          actions: [
            if (_hasChanges)
              TextButton(
                onPressed: _save,
                child: Text(
                  'Save',
                  style: TextStyle(
                    color: colors.border,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionHeader(
              title: 'Friday Tasks',
              color: colors.border,
              onAdd: () => _addTask('friday'),
            ),
            _buildTaskList('friday', _fridayTasks, colors),
            const SizedBox(height: 24),
            _SectionHeader(
              title: 'Saturday Tasks',
              color: colors.border,
              onAdd: () => _addTask('saturday'),
            ),
            _buildTaskList('saturday', _saturdayTasks, colors),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(String day, List<TaskItem> tasks, PhaseColors colors) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex--;
          final item = tasks.removeAt(oldIndex);
          tasks.insert(newIndex, item);
        });
        _markChanged();
      },
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Dismissible(
          key: ValueKey(task.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            color: Colors.red.shade50,
            child: Icon(Icons.delete_outline, color: Colors.red.shade400),
          ),
          onDismissed: (_) => _deleteTask(day, index),
          child: Card(
            key: ValueKey('card-${task.id}'),
            margin: const EdgeInsets.only(bottom: 4),
            child: ListTile(
              leading: ReorderableDragStartListener(
                index: index,
                child: Icon(Icons.drag_handle, color: Colors.grey.shade400),
              ),
              title: _InlineEditField(
                initialText: task.text,
                hintText: 'Task description...',
                onChanged: (text) {
                  task.text = text;
                  _markChanged();
                },
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.more_vert,
                  size: 20,
                  color: Colors.grey.shade500,
                ),
                onPressed: () => _moveTaskToWeek(task, day, index),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  final VoidCallback onAdd;

  const _SectionHeader({
    required this.title,
    required this.color,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add'),
            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
          ),
        ],
      ),
    );
  }
}

class _InlineEditField extends StatefulWidget {
  final String initialText;
  final String hintText;
  final ValueChanged<String> onChanged;

  const _InlineEditField({
    required this.initialText,
    required this.hintText,
    required this.onChanged,
  });

  @override
  State<_InlineEditField> createState() => _InlineEditFieldState();
}

class _InlineEditFieldState extends State<_InlineEditField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      style: const TextStyle(fontSize: 13),
      maxLines: null,
      decoration: InputDecoration(
        hintText: widget.hintText,
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
      onChanged: widget.onChanged,
    );
  }
}
