import React, { useEffect, useState } from "react";
import "./Home.css";
import logo from "../assets/logo.png";
import dish from "../assets/salmon.png";

function Home() {
  // =========================================================
  // NEWSLETTER POPUP STATE
  // Starts hidden, then appears after 5 seconds
  // =========================================================
  const [showNewsletter, setShowNewsletter] = useState(false);

  // =========================================================
  // DELAY POPUP FOR 5 SECONDS
  // =========================================================
  useEffect(() => {
    const timer = setTimeout(() => {
      setShowNewsletter(true);
    }, 5000);

    return () => clearTimeout(timer);
  }, []);

  return (
    <div className="home-container">

      <div className="home-content">

        {/* LEFT IMAGE */}
        <div className="home-image">
          <img src={dish} alt="Featured Dish" />
        </div>

        {/* RIGHT TEXT */}
        <div className="home-text">
          <img src={logo} alt="Café Fausse Logo" className="home-logo" />

          <p className="home-tagline">
            Fine dining welcomes you!
          </p>

          <p className="home-address">
            1234 Culinary Ave, Suite 100,<br />
            Washington, DC 20002
          </p>

          <p className="home-phone">
            📞 (202) 555-4567
          </p>

          <p className="home-hours">
            Monday–Saturday: 5:00 PM – 11:00 PM <br />
            Sunday: 5:00 PM – 9:00 PM
          </p>
        </div>

      </div>

      {/* =====================================================
          NEWSLETTER POPUP
      ====================================================== */}
      {showNewsletter && (
        <div className="newsletter-overlay">
          <div className="newsletter-modal">

            {/* CLOSE BUTTON */}
            <button
              type="button"
              className="newsletter-close"
              onClick={() => setShowNewsletter(false)}
              aria-label="Close newsletter popup"
            >
              ✕
            </button>

            {/* LOGO */}
            <div className="newsletter-logo-wrap">
              <img src={logo} alt="Café Fausse logo" className="newsletter-logo" />
            </div>

            {/* SUBTITLE */}
            <h3 className="newsletter-subtitle">
              Sign up for our Newsletter!
            </h3>

            {/* FORM */}
            <form className="newsletter-form">

              {/* FIRST / LAST NAME ROW */}
              <div className="newsletter-row">
                <div className="newsletter-field">
                  <label>First Name*</label>
                  <input
                    type="text"
                    placeholder="Enter your first name"
                  />
                </div>

                <div className="newsletter-field">
                  <label>Last Name*</label>
                  <input
                    type="text"
                    placeholder="Enter your last name"
                  />
                </div>
              </div>

              {/* EMAIL */}
              <div className="newsletter-field full-width">
                <label>E-mail*</label>
                <input
                  type="email"
                  placeholder="Enter your e-mail address"
                />
              </div>

              {/* PHONE */}
              <div className="newsletter-field full-width">
                <label>Phone number</label>
                <input
                  type="text"
                  placeholder="Enter your phone number (optional)"
                />
              </div>

              {/* NOTE */}
              <p className="newsletter-note">
                We respect your inbox<br />
                Unsubscribe anytime
              </p>

            </form>
          </div>
        </div>
      )}

    </div>
  );
}

export default Home;