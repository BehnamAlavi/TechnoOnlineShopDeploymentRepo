#!/bin/bash
# Transform compose.yaml from Windows paths to Linux paths for production

set -e

echo "=========================================="
echo "Transforming compose.yaml for Linux VPS..."
echo "=========================================="

# Create a copy for production
cp compose.yaml compose.prod.yaml

# Transform Windows absolute paths to Linux paths
echo "Converting Windows paths to Linux paths..."
sed -i 's|C:\\techonline|/opt/techno-shop|g' compose.prod.yaml
sed -i 's|C:\\Users\\ASUS\\source\\repos\\BehnamAlavi\\TechnoOnlineShop\\backend|/opt/techno-shop/backend|g' compose.prod.yaml
sed -i 's|C:\\Users\\ASUS\\source\\repos\\BehnamAlavi\\TechnoOnlineShop\\frontend\\techno-shop-online|/opt/techno-shop/frontend|g' compose.prod.yaml
sed -i 's|C:\\Users\\ASUS\\source\\repos\\Techno_Real\\TechnoOnlineShop\.ControlPanel|/opt/techno-shop/controlpanel|g' compose.prod.yaml
sed -i 's|C:\\technoOnline_shop_DockerCompose|/opt/techno-shop|g' compose.prod.yaml

# Remove version field (deprecated in newer Compose)
sed -i '/^version:/d' compose.prod.yaml

# Convert all remaining backslashes to forward slashes
sed -i 's|\\|/|g' compose.prod.yaml

echo "✓ Transformation complete!"
echo ""
echo "========== Transformed compose.prod.yaml =========="
cat compose.prod.yaml
echo "===================================================="
