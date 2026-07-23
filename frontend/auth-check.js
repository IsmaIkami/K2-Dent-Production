/**
 * DentalCockpit Pro - Authentication Check
 * Vérifie l'authentification avant d'accéder aux pages protégées
 */

(function() {
    'use strict';

    // Petit délai pour laisser le temps à la session d'être disponible
    setTimeout(function() {
        // Vérifier si l'utilisateur est authentifié
        const currentUserStr = localStorage.getItem('currentUser');

        if (!currentUserStr) {
            // Pas authentifié - rediriger vers la page de connexion
            window.location.href = 'login.html';
            return;
        }

        try {
            const currentUser = JSON.parse(currentUserStr);
            console.log('✅ Utilisateur connecté:', currentUser.full_name, `(${currentUser.role})`);
        } catch (e) {
            // localStorage corrompu
            localStorage.clear();
            window.location.href = 'login.html';
            return;
        }

    // Ajouter un bouton de déconnexion dans la navigation
    document.addEventListener('DOMContentLoaded', function() {
        // Trouver le container d'actions dans le topbar
        const topbarActions = document.querySelector('.topbar-actions');
        if (topbarActions) {
            // Créer le bouton de déconnexion
            const logoutBtn = document.createElement('div');
            logoutBtn.className = 'icon-btn';
            logoutBtn.innerHTML = '🚪';
            logoutBtn.title = 'Déconnexion';
            logoutBtn.style.cursor = 'pointer';
            logoutBtn.onclick = function() {
                if (confirm('Êtes-vous sûr de vouloir vous déconnecter ?')) {
                    localStorage.clear();
                    window.location.href = 'login.html';
                }
            };
            topbarActions.appendChild(logoutBtn);
        }
    });
    }, 100); // Délai de 100ms
})();
