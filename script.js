// =====================================================
// D K9 Kennel · Cocachan Dog Breeder Website
// Professional interactive features
// =====================================================

(function() {
    'use strict';

    // -------------------------------------------------
    // 1. LIVE COUNTER - Puppies sold this season
    // -------------------------------------------------

    const heroSide = document.querySelector('.hero-side');
    if (heroSide) {
        if (!document.querySelector('.live-counter')) {
            const counterWrapper = document.createElement('div');
            counterWrapper.className = 'live-counter';
            counterWrapper.style.cssText = `
                margin-top: 0.8rem;
                padding: 0.4rem 1rem;
                background: rgba(30, 30, 42, 0.06);
                border-radius: 40px;
                display: inline-flex;
                align-items: center;
                gap: 0.6rem;
                font-size: 0.85rem;
                color: #3d2c1f;
                font-weight: 500;
                backdrop-filter: blur(2px);
            `;
            counterWrapper.innerHTML = `
                <i class="fas fa-paw" style="color: #b47b5a;"></i>
                <span id="reservedCount">18</span> puppies sold this season
            `;
            const cta = heroSide.querySelector('.hero-cta');
            if (cta) {
                cta.after(counterWrapper);
            } else {
                heroSide.appendChild(counterWrapper);
            }
        }
    }

    let reserved = 18;
    const counterEl = document.getElementById('reservedCount');

    if (counterEl) {
        setInterval(() => {
            const increment = Math.floor(Math.random() * 2) + 1;
            reserved += increment;
            counterEl.textContent = reserved;

            counterEl.style.transition = 'transform 0.15s ease';
            counterEl.style.transform = 'scale(1.2)';
            setTimeout(() => {
                counterEl.style.transform = 'scale(1)';
            }, 150);
        }, 5000);
    }

    // -------------------------------------------------
    // 2. BREED CARD INTERACTIONS
    // -------------------------------------------------

    const breedCards = document.querySelectorAll('.breed-card');
    breedCards.forEach((card) => {
        card.addEventListener('mouseenter', function() {
            const name = this.querySelector('.breed-name')?.textContent || 'Puppy';
            console.log(`[D K9] Interest: ${name}`);
        });

        card.addEventListener('click', function() {
            const name = this.querySelector('.breed-name')?.textContent || 'Puppy';
            const price = this.querySelector('.breed-tag')?.textContent || 'N250,000';
            console.log(`[Inquiry] ${name} - ${price}`);

            const tag = this.querySelector('.breed-tag');
            if (tag) {
                const originalText = tag.textContent;
                const originalBg = tag.style.background;
                tag.textContent = '✦ interested';
                tag.style.background = '#b47b5a';
                tag.style.color = 'white';
                setTimeout(() => {
                    tag.textContent = originalText;
                    tag.style.background = originalBg || '#1e1e2a';
                    tag.style.color = '#ffffff';
                }, 1200);
            }
        });
    });

    // -------------------------------------------------
    // 3. SOCIAL ICON INTERACTIONS
    // -------------------------------------------------

    const socialIcons = document.querySelectorAll('.social-icons i');
    socialIcons.forEach((icon) => {
        icon.addEventListener('click', function() {
            const platform = this.className.replace('fab fa-', '');
            console.log(`[Social] ${platform} clicked`);

            const phone = '09133750885';
            if (platform === 'whatsapp') {
                alert(`📱 Chat with us on WhatsApp: ${phone}`);
            } else {
                alert(`🔗 Follow us on ${platform.charAt(0).toUpperCase() + platform.slice(1)}!`);
            }
        });
    });

    // -------------------------------------------------
    // 4. BUTTON INTERACTIONS
    // -------------------------------------------------

    const priceBtn = document.querySelector('.btn-primary');
    if (priceBtn) {
        priceBtn.addEventListener('click', function() {
            console.log('[CTA] Price clicked - N250,000');
            this.style.transform = 'scale(0.96)';
            setTimeout(() => {
                this.style.transform = 'scale(1)';
            }, 150);
            alert('🐾 Cocachan puppies are N250,000 each.\nIncludes: vaccination, deworming, and health certificate.\nCall 09133750885 for more details!');
        });
    }

    const phoneBtn = document.querySelector('.btn-outline');
    if (phoneBtn) {
        phoneBtn.addEventListener('click', function() {
            console.log('[CTA] Phone clicked: 09133750885');
            alert('📞 Call us at 09133750885\n📍 Located in Anambra State\nMon–Sat · 8am – 6pm');
        });
    }

    // -------------------------------------------------
    // 5. CONTACT CHIP INTERACTIONS
    // -------------------------------------------------

    const contactChips = document.querySelectorAll('.contact-chip');
    contactChips.forEach((chip) => {
        chip.addEventListener('click', function() {
            const text = this.querySelector('span')?.textContent || '';
            if (text.includes('09133750885')) {
                alert(`📞 Call or WhatsApp: 09133750885`);
            } else if (text.includes('Anambra')) {
                alert(`📍 D K9 Kennel\nAnambra State, Nigeria\nViewing by appointment only.`);
            }
        });
    });

    // -------------------------------------------------
    // 6. CONSOLE GREETING
    // -------------------------------------------------

    console.log('🐕 D K9 Kennel · Cocachan Dog Breeder');
    console.log('📍 Anambra State, Nigeria');
    console.log('📞 09133750885');
    console.log('💰 N250,000 per puppy');
    console.log('✅ Interactive features loaded successfully.');

})();