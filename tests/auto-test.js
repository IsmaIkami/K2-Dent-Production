/**
 * AUTO TEST AGENT - DentalCockpit Pro
 * Tests automatiques pour détecter les bugs
 *
 * @author Ismail Sialyen
 * @powered-by RCE AI Engine
 */

class AutoTestAgent {
    constructor() {
        this.errors = [];
        this.warnings = [];
        this.passed = [];
    }

    // Test 1: Date actuelle
    testCurrentDate() {
        const today = new Date();
        const miniMonthYear = document.getElementById('miniMonthYear');

        if (!miniMonthYear) {
            this.errors.push('❌ Mini calendar not found');
            return;
        }

        const displayedMonth = miniMonthYear.textContent;
        const monthNames = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
        const expectedMonth = monthNames[today.getMonth()];
        const expectedYear = today.getFullYear().toString();

        if (displayedMonth.includes(expectedMonth) && displayedMonth.includes(expectedYear)) {
            this.passed.push('✅ Calendar shows correct date');
        } else {
            this.errors.push(`❌ Calendar shows wrong date: ${displayedMonth} (expected: ${expectedMonth} ${expectedYear})`);
        }
    }

    // Test 2: Branding
    testBranding() {
        const logoText = document.querySelector('.logo-text');

        if (!logoText) {
            this.errors.push('❌ Logo not found');
            return;
        }

        if (logoText.textContent.trim() === 'DentalCockpit Pro') {
            this.passed.push('✅ Branding correct: DentalCockpit Pro');
        } else {
            this.errors.push(`❌ Wrong branding: ${logoText.textContent}`);
        }

        // Check for old branding
        const bodyText = document.body.innerText;
        if (bodyText.includes('K2 DENT') || bodyText.includes('K2 Dent')) {
            this.warnings.push('⚠️ "K2 DENT" found in page text');
        }
    }

    // Test 3: Navigation order
    testNavigationOrder() {
        const navItems = Array.from(document.querySelectorAll('.nav-section:first-child .nav-item span:nth-child(2)'));
        const order = navItems.slice(0, 4).map(el => el.textContent.trim());

        const expectedOrder = ['Dashboard Patient', 'Patients', 'Agenda', 'Plan de Traitement'];

        const isCorrect = order.every((item, i) => item === expectedOrder[i]);
        if (isCorrect) {
            this.passed.push('✅ Navigation order correct');
        } else {
            this.errors.push(`❌ Wrong nav order: ${order.join(' → ')}`);
        }
    }

    // Test 4: Console errors
    testConsoleErrors() {
        const consoleErrors = window.__autoTestErrors || [];
        if (consoleErrors.length === 0) {
            this.passed.push('✅ No console errors');
        } else {
            consoleErrors.forEach(err => {
                this.errors.push(`❌ Console error: ${err}`);
            });
        }
    }

    // Test 5: Page title
    testPageTitle() {
        if (document.title.includes('DentalCockpit Pro')) {
            this.passed.push('✅ Page title correct');
        } else {
            this.errors.push(`❌ Wrong page title: ${document.title}`);
        }
    }

    // Run all tests
    async runAll() {
        console.log('🤖 AUTO TEST AGENT - Starting tests...\n');

        this.testPageTitle();
        this.testBranding();
        this.testCurrentDate();
        this.testNavigationOrder();
        this.testConsoleErrors();

        // Report
        console.log('\n📊 TEST RESULTS:\n');

        if (this.passed.length > 0) {
            console.log('✅ PASSED (' + this.passed.length + '):');
            this.passed.forEach(p => console.log('  ' + p));
        }

        if (this.warnings.length > 0) {
            console.log('\n⚠️ WARNINGS (' + this.warnings.length + '):');
            this.warnings.forEach(w => console.log('  ' + w));
        }

        if (this.errors.length > 0) {
            console.log('\n❌ ERRORS (' + this.errors.length + '):');
            this.errors.forEach(e => console.log('  ' + e));
        }

        const total = this.passed.length + this.warnings.length + this.errors.length;
        const passRate = Math.round((this.passed.length / total) * 100);

        console.log(`\n📈 Pass Rate: ${passRate}% (${this.passed.length}/${total})`);

        if (this.errors.length === 0) {
            console.log('\n✅ ALL TESTS PASSED!');
        } else {
            console.log('\n❌ TESTS FAILED - Fix errors above');
        }

        return {
            passed: this.passed.length,
            warnings: this.warnings.length,
            errors: this.errors.length,
            passRate: passRate
        };
    }
}

// Capture console errors
window.__autoTestErrors = [];
const originalError = console.error;
console.error = function(...args) {
    window.__autoTestErrors.push(args.join(' '));
    originalError.apply(console, args);
};

// Auto-run tests after page load
window.addEventListener('load', () => {
    setTimeout(() => {
        const agent = new AutoTestAgent();
        agent.runAll();
    }, 3000); // Wait 3s for page to fully load
});

// Expose globally for manual testing
window.AutoTestAgent = AutoTestAgent;

console.log('🤖 Auto Test Agent loaded - tests will run in 3 seconds after page load');
