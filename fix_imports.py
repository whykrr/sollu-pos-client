import os
import re

lib_dir = 'lib'
package_name = 'sollu_pos_client'

# Build a map of filename -> package path
# E.g., 'sollu_colors.dart' -> 'package:sollu_pos_app/core/theme/sollu_colors.dart'
file_map = {}
for root, dirs, files in os.walk(lib_dir):
    for f in files:
        if f.endswith('.dart'):
            full_path = os.path.join(root, f)
            rel_path = os.path.relpath(full_path, lib_dir)
            pkg_path = f"package:{package_name}/{rel_path}"
            file_map[f] = pkg_path

def fix_imports(filepath):
    with open(filepath, 'r') as file:
        content = file.read()
    
    # Match any local import, like import '../../core/theme/sollu_colors.dart';
    # or import 'pos_layout.dart';
    def replacer(match):
        import_stmt = match.group(0)
        path_str = match.group(1)
        
        if path_str.startswith('package:') or path_str.startswith('dart:'):
            return import_stmt
            
        filename = os.path.basename(path_str)
        if filename in file_map:
            return f"import '{file_map[filename]}';"
        return import_stmt

    new_content = re.sub(r"import\s+['\"](.*?)['\"];", replacer, content)
    
    # Specific fix for main.dart
    if filepath.endswith('main.dart'):
        new_content = new_content.replace("import 'core/theme/sollu_colors.dart';", f"import 'package:{package_name}/core/theme/sollu_colors.dart';")
        new_content = new_content.replace("import 'core/routing/app_router.dart';", f"import 'package:{package_name}/core/routing/app_router.dart';")
        new_content = new_content.replace("import 'features/pos/presentation/providers/shortcut_provider.dart';", f"import 'package:{package_name}/features/pos/presentation/providers/shortcut_provider.dart';")
        
    if new_content != content:
        with open(filepath, 'w') as file:
            file.write(new_content)
        print(f"Fixed imports in {filepath}")

for root, dirs, files in os.walk(lib_dir):
    for f in files:
        if f.endswith('.dart'):
            fix_imports(os.path.join(root, f))
            
# Also fix test file
if os.path.exists('test/widget_test.dart'):
    with open('test/widget_test.dart', 'r') as f:
        c = f.read()
    c = c.replace("import 'package:sollu_pos_app/main.dart';", "import 'package:sollu_pos_app/main.dart';")
    c = c.replace("MyApp()", "SolluPosApp()")
    with open('test/widget_test.dart', 'w') as f:
        f.write(c)
