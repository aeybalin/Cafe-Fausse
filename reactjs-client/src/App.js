import { Routes, Route } from "react-router-dom";
import { useState } from "react";

import Home from "./components/Home";
import Menu from "./components/Menu";
import Reservation from "./components/Reservation";
import AboutUs from "./components/AboutUs";
import Gallery from "./components/Gallery";
import Admin from "./components/Admin";
import Navbar from "./components/Navbar";
import Footer from "./components/Footer";

import "./App.css";

function App() {
  // =========================================================
  // ✅ GLOBAL NEWSLETTER STATE
  // =========================================================
  const [showNewsletter, setShowNewsletter] = useState(false);

  // ✅ function used by footer + homepage
  const openNewsletter = () => {
    setShowNewsletter(true);
  };

  const closeNewsletter = () => {
    setShowNewsletter(false);
  };

  return (
    <>
      <Navbar />

      <Routes>
        {/* ✅ Pass control to Home */}
        <Route
          path="/"
          element={
            <Home
              showNewsletter={showNewsletter}
              setShowNewsletter={setShowNewsletter}
            />
          }
        />

        <Route path="/menu" element={<Menu />} />
        <Route path="/reservation" element={<Reservation />} />
        <Route path="/about" element={<AboutUs />} />
        <Route path="/gallery" element={<Gallery />} />
        <Route path="/admin" element={<Admin />} />
      </Routes>

      {/* ✅ Footer can now trigger popup */}
      <Footer openNewsletter={openNewsletter} />

      {/* =====================================================
          ✅ GLOBAL NEWSLETTER POPUP
      ====================================================== */}
      {showNewsletter && (
        <div className="newsletter-overlay">
          <div className="newsletter-modal">
            {/* CLOSE BUTTON */}
            <button
              className="newsletter-close"
              onClick={closeNewsletter}
              aria-label="Close newsletter popup"
            >
              ✕
            </button>

            {/* LOGO */}
            <div className="newsletter-logo-wrap">
              <img src={require("./assets/logo.png")} alt="logo" className="newsletter-logo" />
            </div>

            {/* SUBTITLE */}
            <h4 className="newsletter-subtitle">
              Sign up for our Newsletter!
            </h4>

            {/* FORM  */}
            <div className="newsletter-form">

            {/* FIRST / LAST NAME ROW */}
            <div className="newsletter-row">
              <div className="newsletter-field">
                <label>First Name*</label>
                <input type="text" />
              </div>

              <div className="newsletter-field">
                <label>Last Name*</label>
                <input type="text" />
              </div>
            </div>

            {/* EMAIL */}
            <div className="newsletter-field full-width">
              <label>E-mail*</label>
              <input type="email" />
            </div>

            {/* PHONE */}
            <div className="newsletter-field full-width">
              <label>Phone number (optional) </label>
              <input type="text" />
            </div>

          </div>

            <p className="newsletter-note">
              We respect your inbox
              <br />
              Unsubscribe anytime
            </p>
          </div>
        </div>
      )}
    </>
  );
}

export default App;