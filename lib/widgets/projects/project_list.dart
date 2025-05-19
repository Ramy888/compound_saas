import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/project_model.dart';

class ProjectListView extends StatelessWidget {
  final List<ProjectModel> projects;
  final Function(ProjectModel) onProjectTap;
  final Function(ProjectModel)? onProjectRemove;
  final Function(ProjectModel)? onProjectRestore;

  const ProjectListView({
    Key? key,
    required this.projects,
    required this.onProjectTap,
    this.onProjectRemove,
    this.onProjectRestore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return Center(
        child: Text('No projects found'),
      );
    }

    return ListView.builder(
      itemCount: projects.length,
      padding: EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final project = projects[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () => onProjectTap(project),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (project.projectCover != null &&
                    project.projectCover!.isNotEmpty)
                  Image.network(
                    project.projectCover!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.broken_image,
                          size: 64,
                          color: Colors.grey[600],
                        ),
                      );
                    },
                  ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              project.projectName ?? 'Unnamed Project',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          if (!project.isActive)
                            Chip(
                              label: Text('Removed'),
                              backgroundColor: Colors.red[100],
                              labelStyle: TextStyle(color: Colors.red[900]),
                            ),
                        ],
                      ),
                      if (project.projectNameAr != null &&
                          project.projectNameAr!.isNotEmpty)
                        Text(
                          project.projectNameAr!,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontFamily: 'Arial',
                          ),
                        ),
                      SizedBox(height: 8),
                      Text(
                        project.projectType ?? 'No type specified',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              project.projectAddress ?? 'No address specified',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Created ${timeago.format(project.createdAt)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          if (project.isActive && onProjectRemove != null)
                            TextButton.icon(
                              onPressed: () => onProjectRemove!(project),
                              icon: Icon(Icons.delete_outline),
                              label: Text('Remove'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                            )
                          else if (!project.isActive && onProjectRestore != null)
                            TextButton.icon(
                              onPressed: () => onProjectRestore!(project),
                              icon: Icon(Icons.restore),
                              label: Text('Restore'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.green,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}