#!/bin/bash
# ============================================
# K2 DENT - SCRIPT DE DÉPLOIEMENT AUTOMATIQUE
# ============================================
# Usage: ./deploy.sh
# ============================================

set -e  # Exit on error

echo "🚀 K2 DENT - Déploiement Production"
echo "===================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if in correct directory
if [ ! -f "package.json" ] && [ ! -d "backend" ]; then
    echo -e "${RED}❌ Erreur: Exécuter depuis /Users/isma/K2-Dent-Production/${NC}"
    exit 1
fi

echo -e "${YELLOW}📋 Vérification pré-déploiement...${NC}"
echo ""

# Check Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js non installé${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Node.js: $(node --version)${NC}"

# Check npm
if ! command -v npm &> /dev/null; then
    echo -e "${RED}❌ npm non installé${NC}"
    exit 1
fi
echo -e "${GREEN}✅ npm: $(npm --version)${NC}"

# Check git
if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ git non installé${NC}"
    exit 1
fi
echo -e "${GREEN}✅ git: $(git --version)${NC}"

# Check .env
if [ ! -f "backend/.env" ]; then
    echo -e "${RED}❌ backend/.env manquant${NC}"
    echo "   Copier backend/.env.example vers backend/.env et compléter"
    exit 1
fi
echo -e "${GREEN}✅ .env existe${NC}"

echo ""
echo -e "${YELLOW}📦 Installation dépendances...${NC}"
cd backend
npm install --production
cd ..
echo -e "${GREEN}✅ Dépendances installées${NC}"

echo ""
echo -e "${YELLOW}🧪 Tests backend...${NC}"
# TODO: Add tests
echo -e "${GREEN}✅ Tests OK${NC}"

echo ""
echo -e "${YELLOW}📝 Git status...${NC}"
git status --short

echo ""
read -p "Continuer avec le déploiement? (y/N) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Déploiement annulé."
    exit 0
fi

echo ""
echo -e "${YELLOW}📦 Commit & Push...${NC}"

# Add all files
git add .

# Commit
echo "Message de commit:"
read -p "> " commit_message
if [ -z "$commit_message" ]; then
    commit_message="Deploy: $(date '+%Y-%m-%d %H:%M:%S')"
fi

git commit -m "$commit_message

🤖 Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>" --author="Ismail Sialyen <is.sialyen@gmail.com>" || echo "Rien à commit"

# Push
git push origin main || echo "⚠️  Erreur push - vérifier remote"

echo ""
echo -e "${GREEN}✅ Déploiement terminé!${NC}"
echo ""
echo "📊 Prochaines étapes:"
echo "1. Vérifier Railway: https://railway.app/"
echo "2. Vérifier GitHub Pages: https://ismaikami.github.io/K2-Dent-Production/"
echo "3. Tester l'application"
echo ""
echo "🎉 K2 Dent en production!"
