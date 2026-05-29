import React, { useMemo, useState } from "react";
import "./Reservation.css";
import logo from "../assets/logo.png"; // remove this line if you do not want to show the logo in finalize/confirmed state
import { Link } from "react-router-dom";

function Reservation() {
  // =========================================================
  // MAIN SEARCH STATE
  // =========================================================
  const [date, setDate] = useState("");
  const [people, setPeople] = useState("");
  const [time, setTime] = useState("");

  // =========================================================
  // PAGE STATUS
  // idle            -> first screen
  // noAvailability  -> unavailable message shown
  // found           -> finalize reservation screen
  // confirmed       -> confirmation success screen
  // =========================================================
  const [status, setStatus] = useState("idle");

  // =========================================================
  // RESERVATION DETAILS FORM STATE
  // =========================================================
  const [details, setDetails] = useState({
    firstName: "",
    lastName: "",
    email: "",
    phone: "",
    occasion: "",
    newsletter: false,
    textUpdates: false,
  });

  // =========================================================
  // PEOPLE OPTIONS (1 through 12)
  // =========================================================
  const peopleOptions = Array.from({ length: 12 }, (_, i) => i + 1);

  // =========================================================
  // UTILITY: FORMAT DATE FOR DISPLAY
  // Example output: Mon, June 15, 2026
  // =========================================================
  function formatDisplayDate(dateStr) {
    if (!dateStr) return "";
    const selected = new Date(`${dateStr}T12:00:00`);
    return selected.toLocaleDateString("en-US", {
      weekday: "short",
      month: "long",
      day: "numeric",
      year: "numeric",
    });
  }

  // =========================================================
  // UTILITY: FORMAT MINUTES -> 12 HOUR TIME
  // Example: 17 * 60 -> 5:00 PM
  // =========================================================
  function to12Hour(minutes) {
    const hrs24 = Math.floor(minutes / 60);
    const mins = minutes % 60;
    const suffix = hrs24 >= 12 ? "PM" : "AM";
    const hrs12 = hrs24 % 12 === 0 ? 12 : hrs24 % 12;

    return `${hrs12}:${String(mins).padStart(2, "0")} ${suffix}`;
  }

  // =========================================================
  // BUILD TIME OPTIONS DEPENDING ON DAY SELECTED
  // Sunday = 5 PM to 7 PM
  // Monday-Saturday = 5 PM to 9 PM
  // 15-minute intervals
  // =========================================================
  const timeOptions = useMemo(() => {
    if (!date) return [];

    const selected = new Date(`${date}T12:00:00`);
    const day = selected.getDay(); // 0 = Sunday

    const startMinutes = 17 * 60; // 5:00 PM
    const endMinutes = day === 0 ? 19 * 60 : 21 * 60; // Sunday 7 PM, others 9 PM

    const slots = [];

    for (let mins = startMinutes; mins <= endMinutes; mins += 15) {
      const end = mins + 15;

      slots.push({
        value: `${String(Math.floor(mins / 60)).padStart(2, "0")}:${String(
          mins % 60
        ).padStart(2, "0")}`,
        label: `${to12Hour(mins)} – ${to12Hour(end)}`,
      });
    }

    return slots;
  }, [date]);

  // =========================================================
  // SELECTED DISPLAY VALUES
  // =========================================================
  const selectedTimeLabel =
    timeOptions.find((slot) => slot.value === time)?.label || "";

  const selectedPeopleLabel =
    people && Number(people) === 1 ? "1 guest" : people ? `${people} guests` : "";

  // =========================================================
  // HANDLE "FIND A TABLE"
  // NOTE:
  // Right now this is mock/demo logic until DB is wired.
  // Replace mock section with API/database call later.
  // =========================================================
  function handleFindTable(e) {
    e.preventDefault();

    // basic validation
    if (!date || !people || !time) {
      setStatus("noAvailability");
      return;
    }

    // ---------------------------------------------------------
    // MOCK AVAILABILITY RULE FOR DEMO
    // Example unavailable case:
    // June 15, 2026 at 7:00 PM for parties of 9 or more
    // ---------------------------------------------------------
    if (date === "2026-06-15" && time === "19:00" && Number(people) >= 9) {
      setStatus("noAvailability");
      return;
    }

    // otherwise move to finalize
    setStatus("found");
  }

  // =========================================================
  // HANDLE DETAILS FORM INPUTS
  // =========================================================
  function handleDetailsChange(e) {
    const { name, value, type, checked } = e.target;

    setDetails((prev) => ({
      ...prev,
      [name]: type === "checkbox" ? checked : value,
    }));
  }

  // =========================================================
  // HANDLE FINAL RESERVATION SUBMIT
  // NOTE:
  // This is also mock/demo for now.
  // Replace with API/database confirmation later.
  // =========================================================
  function handleCompleteReservation(e) {
    e.preventDefault();

    if (!details.firstName || !details.lastName || !details.email) {
      return;
    }

    setStatus("confirmed");
  }

  // =========================================================
  // RESET FLOW BACK TO SEARCH
  // Handy if you want to add a "try again" button later
  // =========================================================
  function resetReservationFlow() {
    setStatus("idle");
    setDetails({
      firstName: "",
      lastName: "",
      email: "",
      phone: "",
      occasion: "",
      newsletter: false,
      textUpdates: false,
    });
  }

  return (
    <div className="reservation-page">
      {/* =====================================================
          TOP CARD
          Initial / No Availability / Finalize / Confirmed
      ====================================================== */}
      <section className="reservation-card">
        {/* ---------------------------------------------------
            INITIAL / NO AVAILABILITY HEADER
        ---------------------------------------------------- */}
        {(status === "idle" || status === "noAvailability") && (
          <>
            <h1 className="reservation-title">MAKE A RESERVATION</h1>

            {status === "noAvailability" && (
              <div className="reservation-alert error-alert">
                <span className="alert-icon">⚠</span>
                <span>
                  At the moment, there’s no online availability within 2.5 hours of{" "}
                  {formatDisplayDate(date)} {selectedTimeLabel}
                </span>
              </div>
            )}

            {/* SEARCH FORM */}
            <form className="reservation-search-row" onSubmit={handleFindTable}>
              {/* DATE */}
              <div className="search-field">
                <label htmlFor="date">DATE</label>

                {/* Custom visible box */}
                <div
                  className="custom-date-wrapper"
                  onClick={() => {
                    const input = document.getElementById("date");
                    if (input?.showPicker) {
                      input.showPicker();
                    } else {
                      input?.focus();
                    }
                  }}
                >
                  <span className={!date ? "placeholder-text" : ""}>
                    {date ? formatDisplayDate(date) : "Select a date"}
                  </span>
                </div>

                {/* Hidden real date input */}
                <input
                  id="date"
                  type="date"
                  value={date}
                  onChange={(e) => {
                    setDate(e.target.value);
                    setTime(""); // reset time whenever date changes
                  }}
                  className="hidden-date-input"
                />
              </div>

              {/* PEOPLE */}
              <div className="search-field select-field">
                <label htmlFor="people">PEOPLE</label>
                <select
                  id="people"
                  value={people}
                  onChange={(e) => setPeople(e.target.value)}
                  className={!people ? "placeholder-select" : ""}
                >
                  <option value="" disabled hidden>
                    Select number of guests
                  </option>

                  {peopleOptions.map((count) => (
                    <option key={count} value={count}>
                      {count} {count === 1 ? "guest" : "guests"}
                    </option>
                  ))}
                </select>
              </div>

              {/* TIME */}
              <div className="search-field select-field">
                <label htmlFor="time">TIME</label>
                <select
                  id="time"
                  value={time}
                  onChange={(e) => setTime(e.target.value)}
                  className={!time ? "placeholder-select" : ""}
                  disabled={!date}
                >
                  <option value="" disabled hidden>
                    Select time
                  </option>

                  {timeOptions.map((slot) => (
                    <option key={slot.value} value={slot.value}>
                      {slot.label}
                    </option>
                  ))}
                </select>
              </div>

              {/* FIND A TABLE BUTTON */}
              <div className="search-button-wrap">
                {/* hidden label spacer for alignment */}
                <label className="search-button-label" aria-hidden="true">
                  spacer
                </label>

                <button type="submit" className="find-table-btn">
                  FIND A TABLE
                </button>
              </div>
            </form>
          </>
        )}

        {/* ---------------------------------------------------
            FINALIZE RESERVATION HEADER / SUMMARY
        ---------------------------------------------------- */}
        {status === "found" && (
          <>
            <img src={logo} alt="Café Fausse logo" className="reservation-logo" />
            <h1 className="reservation-subtitle">RESERVATION</h1>

            <div className="reservation-summary">
              <div className="summary-item">📅 {formatDisplayDate(date)}</div>
              <div className="summary-item">👤 {selectedPeopleLabel}</div>
              <div className="summary-item">🕒 {selectedTimeLabel}</div>
            </div>

            <div className="dress-code-box">
              <p>
                <strong>Dress code:</strong> You will be asked to be dressed elegantly
                and correctly in the restaurant. Shorts, sportswear not accepted.
              </p>
            </div>
          </>
        )}

        {/* ---------------------------------------------------
            CONFIRMED STATE
        ---------------------------------------------------- */}
        {status === "confirmed" && (
          <>
            <h1 className="reservation-title">RESERVATION CONFIRMED</h1>

            <div className="reservation-alert success-alert">
              <span className="alert-icon">✓</span>
              <span>Success! Your reservation is confirmed</span>
            </div>

            <div className="reservation-summary">
              <div className="summary-item">📅 {formatDisplayDate(date)}</div>
              <div className="summary-item">👤 {selectedPeopleLabel}</div>
              <div className="summary-item">🕒 {selectedTimeLabel}</div>
            </div>

            <div className="confirmed-name">
              {details.firstName} {details.lastName} – {details.email}
            </div>

            <div className="confirmed-message">
              A confirmation email has been sent to you. Please contact us with any
              modification.
            </div>

            {/* Optional tiny reset button for dev/testing */}
            <Link to="/" className="secondary-link-btn">
              GO HOME
            </Link>


          </>
        )}
      </section>

      {/* =====================================================
          FINALIZE DETAILS FORM
          Only visible when a table was found
      ====================================================== */}
      {status === "found" && (
        <section className="reservation-details-section">
          <h2 className="details-heading">RESERVATION DETAILS</h2>

          <form className="details-form" onSubmit={handleCompleteReservation}>
            {/* first / last name row */}
            <div className="two-column-row">
              <div className="details-field">
                <label htmlFor="firstName">First Name*</label>
                <input
                  id="firstName"
                  type="text"
                  name="firstName"
                  placeholder="Enter your name"
                  value={details.firstName}
                  onChange={handleDetailsChange}
                />
              </div>

              <div className="details-field">
                <label htmlFor="lastName">Last Name*</label>
                <input
                  id="lastName"
                  type="text"
                  name="lastName"
                  placeholder="Enter your name"
                  value={details.lastName}
                  onChange={handleDetailsChange}
                />
              </div>
            </div>

            {/* email */}
            <div className="details-field">
              <label htmlFor="email">E-mail*</label>
              <input
                id="email"
                type="email"
                name="email"
                placeholder="Enter your e-mail address"
                value={details.email}
                onChange={handleDetailsChange}
              />
            </div>

            {/* phone */}
            <div className="details-field">
              <label htmlFor="phone">Phone number (optional)</label>
              <input
                id="phone"
                type="text"
                name="phone"
                placeholder="Enter your phone number"
                value={details.phone}
                onChange={handleDetailsChange}
              />
            </div>

            {/* occasion */}
            <div className="details-field">
              <label htmlFor="occasion">Occasion (optional)</label>
              <input
                id="occasion"
                type="text"
                name="occasion"
                placeholder="Enter your occasion"
                value={details.occasion}
                onChange={handleDetailsChange}
              />
            </div>

            <p className="mandatory-note">All fields with * are mandatory</p>

            {/* newsletter checkbox */}
            <label className="checkbox-row">
              <input
                type="checkbox"
                name="newsletter"
                checked={details.newsletter}
                onChange={handleDetailsChange}
              />
              Please add me to your Newsletter
            </label>

            {/* text updates checkbox */}
            <label className="checkbox-row">
              <input
                type="checkbox"
                name="textUpdates"
                checked={details.textUpdates}
                onChange={handleDetailsChange}
              />
              Yes, I want to get text updates and reminders about my reservation
            </label>

            {/* final button */}
            <button type="submit" className="complete-reservation-btn">
              Complete my reservation
            </button>
          </form>
        </section>
      )}
    </div>
  );
}

export default Reservation;