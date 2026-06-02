import React, { useEffect } from "react";
import "./Home.css";
import logo from "../assets/logo.png";
import dish from "../assets/salmon.png";

function Home({ setShowNewsletter }) {

  // =========================================================
  // DELAY POPUP FOR 5 SECONDS
  // =========================================================
 useEffect(() => {
  const timer = setTimeout(() => {
    setShowNewsletter(true);
  }, 5000);

  return () => clearTimeout(timer);
}, [setShowNewsletter]);

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
          NEWSLETTER POPUP moved to app.js since we are adding 
          to footer also
      ====================================================== */}
      

    </div>
  );
}

export default Home;