// Smooth scrolling for navigation links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            target.scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
        }
    });
});

// Contact form submission
document.querySelector('.contact-form').addEventListener('submit', function(e) {
    e.preventDefault();
    alert('Thank you for your message! We will get back to you soon. 🐕');
    this.reset();
});

// Inquire button functionality
document.querySelectorAll('.inquire-btn').forEach(button => {
    button.addEventListener('click', function(e) {
        const puppyName = this.parentElement.querySelector('h3').textContent;
        alert(`Thank you for your interest in ${puppyName}! Please contact us for more information. Divine is excited to meet you! 🐕✨`);
    });
});

// CTA button scroll to puppies
document.querySelector('.cta-btn').addEventListener('click', function() {
    document.getElementById('puppies').scrollIntoView({ behavior: 'smooth' });
});

// Add scroll effect to navbar
window.addEventListener('scroll', function() {
    const navbar = document.querySelector('.navbar');
    if (window.scrollY > 50) {
        navbar.style.boxShadow = '0 5px 15px rgba(0, 0, 0, 0.2)';
    } else {
        navbar.style.boxShadow = '0 2px 5px rgba(0, 0, 0, 0.1)';
    }
});

// Divine mascot interaction
document.querySelector('.divine-svg').addEventListener('click', function() {
    alert('Hi! I\'m Divine! 🐕✨ Welcome to our dog breeding family! Pet me for good luck!');
    this.style.transform = 'scale(1.1) rotate(5deg)';
    setTimeout(() => {
        this.style.transform = '';
    }, 500);
});

// Fade in elements on scroll
const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -50px 0px'
};

const observer = new IntersectionObserver(function(entries) {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.style.opacity = '1';
            entry.target.style.transform = 'translateY(0)';
        }
    });
}, observerOptions);

// Observe breed cards and puppy cards
document.querySelectorAll('.breed-card, .puppy-card, .feature').forEach(el => {
    el.style.opacity = '0';
    el.style.transform = 'translateY(20px)';
    el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
    observer.observe(el);
});

console.log('🐕 Divine\'s Dog Breeder Website loaded successfully!');