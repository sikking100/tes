import { BreadcrumbItem, Breadcrumb, BreadcrumbLink } from '@chakra-ui/breadcrumb'
import React from 'react'
import { Link } from 'react-router-dom'

interface BreadCrumbProps {
  href: string
  label: string
}

interface Props {
  item: BreadCrumbProps[]
}

export const BreadCrumb: React.FC<Props> = (props) => {
  return (
    <>
      <Breadcrumb fontWeight='medium' fontSize='sm'>
        {props.item.map((i, k) => (
          <BreadcrumbItem key={k}>
            <BreadcrumbLink as={Link} to={i.href}>
              {i.label}
            </BreadcrumbLink>
          </BreadcrumbItem>
        ))}
      </Breadcrumb>
    </>
  )
}
