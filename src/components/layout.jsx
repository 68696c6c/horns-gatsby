import React from 'react'
import PropTypes from 'prop-types'
import { graphql, useStaticQuery } from 'gatsby'
import { ThemeProvider } from 'emotion-theming'
import { css, Global } from '@emotion/core'

import { baseTheme, getBaseStyles } from 'horns'

import Footer from './footer'
import Header from './header'

const Layout = ({ children }) => {
  const data = useStaticQuery(graphql`
    query SiteTitleQuery {
      site {
        siteMetadata {
          title
        }
      }
    }
  `)

  return (
    <ThemeProvider theme={baseTheme}>
      <Global styles={css`${getBaseStyles(baseTheme)}`} />
      <Header siteTitle={data.site.siteMetadata.title} />
        <main>{children}</main>
      <Footer />
    </ThemeProvider>
  )
}

Layout.propTypes = {
  children: PropTypes.node.isRequired,
}

export default Layout
