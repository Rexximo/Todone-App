import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../core/theme/app_colors.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getPriorityColor() {
    switch (widget.task.priority) {
      case 1:
        return AppColors.success;
      case 2:
        return AppColors.warning;
      case 3:
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  Color _getSilhouetteColor() {
    return _getPriorityColor().withOpacity(0.12);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
      },
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Slidable(
          key: ValueKey(widget.task.id),
          endActionPane: ActionPane(
            motion: const StretchMotion(),
            children: [
              SlidableAction(
                onPressed: (_) => widget.onDelete(),
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                icon: Icons.delete_rounded,
                label: 'Delete',
                borderRadius: BorderRadius.circular(20),
              ),
            ],
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getPriorityColor().withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Stack(
              children: [
                // Background Silhouette Pattern
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CustomPaint(
                      painter: SilhouettePainter(
                        color: _getSilhouetteColor(),
                      ),
                    ),
                  ),
                ),
                
                // Decorative circles
                Positioned(
                  right: -20,
                  top: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getPriorityColor().withOpacity(0.06),
                    ),
                  ),
                ),
                Positioned(
                  left: -30,
                  bottom: -30,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getPriorityColor().withOpacity(0.04),
                    ),
                  ),
                ),
                
                // Content
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onTap,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          // Checkbox with glow effect
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 300),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: GestureDetector(
                                  onTap: widget.onToggle,
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: widget.task.isCompleted
                                          ? _getPriorityColor()
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: widget.task.isCompleted
                                            ? _getPriorityColor()
                                            : _getPriorityColor().withOpacity(0.5),
                                        width: 2.5,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: widget.task.isCompleted
                                        ? const Icon(
                                            Icons.check_rounded,
                                            size: 20,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 16),
                          
                          // Task Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.task.title,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          decoration: widget.task.isCompleted
                                              ? TextDecoration.lineThrough
                                              : null,
                                          color: widget.task.isCompleted
                                              ? AppColors.textHint
                                              : AppColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.3,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getPriorityColor().withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: _getPriorityColor().withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        widget.task.getPriorityLabel(),
                                        style: TextStyle(
                                          color: _getPriorityColor(),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (widget.task.description.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    widget.task.description,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: widget.task.isCompleted
                                          ? AppColors.textHint
                                          : AppColors.textSecondary,
                                      height: 1.4,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                if (widget.task.dueDate != null) ...[
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getPriorityColor().withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: _getPriorityColor().withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.calendar_today_rounded,
                                          size: 12,
                                          color: widget.task.isCompleted
                                              ? AppColors.textHint
                                              : _getPriorityColor(),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          DateFormat('MMM dd, yyyy').format(widget.task.dueDate!),
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: widget.task.isCompleted
                                                ? AppColors.textHint
                                                : _getPriorityColor(),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Painter for Silhouette Pattern
class SilhouettePainter extends CustomPainter {
  final Color color;

  SilhouettePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw geometric shapes as silhouette
    final path = Path();
    
    // Triangle 1
    path.moveTo(size.width * 0.8, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.3);
    path.close();
    
    // Triangle 2
    path.moveTo(0, size.height * 0.7);
    path.lineTo(size.width * 0.2, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    // Hexagon in center
    final centerX = size.width * 0.7;
    final centerY = size.height * 0.6;
    final radius = 30.0;
    
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60.0) * 3.14159 / 180;
      final x = centerX + radius * cos(angle);
      final y = centerY + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    
    canvas.drawPath(path, paint);
    
    // Draw dots pattern
    for (int i = 0; i < 15; i++) {
      final x = (i * 40.0) % size.width;
      final y = ((i * 40.0) ~/ size.width) * 40.0;
      canvas.drawCircle(
        Offset(x + 10, y + 10),
        2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
  
  double cos(double angle) => (angle == 0) ? 1.0 : (angle == 1.5708) ? 0.0 : 
      (angle == 3.14159) ? -1.0 : (angle == 4.71239) ? 0.0 : 
      1.0 - (angle * angle) / 2 + (angle * angle * angle * angle) / 24;
      
  double sin(double angle) => (angle == 0) ? 0.0 : (angle == 1.5708) ? 1.0 : 
      (angle == 3.14159) ? 0.0 : (angle == 4.71239) ? -1.0 : 
      angle - (angle * angle * angle) / 6 + (angle * angle * angle * angle * angle) / 120;
}